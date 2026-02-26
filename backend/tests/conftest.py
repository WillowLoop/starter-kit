"""Test infrastructure for the backend.

Locally: uses aiosqlite in-memory database for fast tests without Docker.
CI: uses PostgreSQL via a service container (set via DATABASE_URL env var).
"""

import os
import warnings
from collections.abc import AsyncGenerator

import pytest
from httpx import ASGITransport, AsyncClient
from sqlalchemy import event
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine

# === Defaults for local dev — CI overrides via workflow env ===
os.environ.setdefault("APP_ENV", "testing")
os.environ.setdefault("SECRET_KEY", "test-secret-key-do-not-use-in-production")
os.environ.setdefault("DATABASE_URL", "sqlite+aiosqlite://")
# === End environment setup — imports below this line ===

from shared.db.base import Base
from shared.db.session import get_session

test_engine = create_async_engine(os.environ["DATABASE_URL"], echo=False)


@pytest.fixture(scope="session", autouse=True)
async def _log_db_backend() -> AsyncGenerator[None, None]:
    dialect = test_engine.dialect.name
    warnings.warn(f"[test-infra] Running tests against: {dialect}", stacklevel=1)
    yield


@pytest.fixture(scope="session", autouse=True)
async def _create_tables() -> AsyncGenerator[None, None]:
    async with test_engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield
    async with test_engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
    await test_engine.dispose()


@pytest.fixture
async def session() -> AsyncGenerator[AsyncSession, None]:
    """Provide a transactional session that rolls back after each test.

    Uses the standard SQLAlchemy SAVEPOINT pattern:
    1. Open a real connection + transaction
    2. Start a SAVEPOINT (nested transaction)
    3. When app code calls commit(), it only commits the SAVEPOINT
    4. An event listener automatically restarts the SAVEPOINT
    5. After the test, roll back the outer transaction (undoing everything)
    """
    async with test_engine.connect() as connection:
        transaction = await connection.begin()
        session = AsyncSession(bind=connection, expire_on_commit=False)

        # Start a SAVEPOINT
        await connection.begin_nested()

        # Restart SAVEPOINT after each commit so the session stays usable
        @event.listens_for(session.sync_session, "after_transaction_end")
        def restart_savepoint(sess, trans):  # type: ignore[no-untyped-def]
            if trans.nested and not trans._parent.nested:  # type: ignore[union-attr]
                sess.begin_nested()

        yield session

        await session.close()
        await transaction.rollback()


@pytest.fixture
async def client(session: AsyncSession) -> AsyncGenerator[AsyncClient, None]:
    from app.main import create_app

    app = create_app()

    async def override_get_session() -> AsyncGenerator[AsyncSession, None]:
        yield session

    app.dependency_overrides[get_session] = override_get_session

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        yield ac
