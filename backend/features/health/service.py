import structlog
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from features.health.schema import HealthResponse
from shared.config import settings

logger = structlog.get_logger()


class HealthService:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def check(self) -> HealthResponse:
        db_status = await self._check_database()
        redis_status = await self._check_redis()

        overall = "healthy" if db_status == "up" and redis_status != "down" else "unhealthy"

        return HealthResponse(
            status=overall,
            database=db_status,
            redis=redis_status,
            version=settings.app_env,
        )

    async def _check_database(self) -> str:
        try:
            await self.session.execute(text("SELECT 1"))
            return "up"
        except Exception:
            await logger.aexception("database_health_check_failed")
            return "down"

    async def _check_redis(self) -> str:
        if not settings.redis_url:
            return "skipped"

        try:
            import redis.asyncio as aioredis

            client = aioredis.from_url(settings.redis_url)  # type: ignore[no-untyped-call]
            await client.ping()
            await client.aclose()
            return "up"
        except Exception:
            await logger.aexception("redis_health_check_failed")
            return "down"
