from collections.abc import AsyncGenerator
from contextlib import asynccontextmanager

import structlog
from fastapi import FastAPI

from features.health.router import router as health_router
from features.items.router import router as items_router
from shared.config import settings
from shared.lib.exceptions import register_exception_handlers
from shared.middleware.cors import add_cors_middleware
from shared.middleware.logging import RequestLoggingMiddleware

logger = structlog.get_logger()


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncGenerator[None, None]:
    await logger.ainfo("startup", env=settings.app_env)
    yield
    await logger.ainfo("shutdown")


def create_app() -> FastAPI:
    app = FastAPI(
        title="AIpoweredMakers API",
        version="0.1.0",
        docs_url="/docs" if settings.is_development else None,
        redoc_url="/redoc" if settings.is_development else None,
        lifespan=lifespan,
    )

    add_cors_middleware(app)
    app.add_middleware(RequestLoggingMiddleware)

    register_exception_handlers(app)

    app.include_router(health_router)
    app.include_router(items_router, prefix="/api/v1/items", tags=["items"])

    return app


app = create_app()
