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


def _init_sentry() -> None:
    if not settings.sentry_dsn:
        return
    import sentry_sdk

    sentry_sdk.init(
        dsn=settings.sentry_dsn,
        environment=settings.sentry_environment or settings.app_env,
        traces_sample_rate=settings.sentry_traces_sample_rate,
        send_default_pii=False,
    )


def create_app() -> FastAPI:
    _init_sentry()

    app = FastAPI(
        title="AIpoweredMakers API",
        version="0.1.0",
        openapi_url="/openapi.json" if settings.is_development else None,
        docs_url="/docs" if settings.is_development else None,
        redoc_url="/redoc" if settings.is_development else None,
        lifespan=lifespan,
    )

    add_cors_middleware(app)

    if not settings.is_testing:
        from slowapi.errors import RateLimitExceeded

        from shared.middleware.rate_limit import limiter, rate_limit_exceeded_handler

        app.state.limiter = limiter
        app.add_exception_handler(RateLimitExceeded, rate_limit_exceeded_handler)

    app.add_middleware(RequestLoggingMiddleware)

    register_exception_handlers(app)

    app.include_router(health_router)
    app.include_router(items_router, prefix="/api/v1/items", tags=["items"])

    return app


app = create_app()
