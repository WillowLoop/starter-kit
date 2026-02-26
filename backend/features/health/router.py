from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from features.health.schema import HealthResponse
from features.health.service import HealthService
from shared.db.session import get_session

router = APIRouter()


@router.get("/health", response_model=HealthResponse)
async def health_check(session: AsyncSession = Depends(get_session)) -> HealthResponse:
    service = HealthService(session)
    return await service.check()


# Liveness probe — intentionally dependency-free (no DB, no Redis).
# Do NOT add Depends() here; k8s/Docker must get 200 even when dependencies are down.
@router.get("/health/live")
async def health_live() -> dict:
    """Shallow liveness probe — no I/O. Used by Dockerfile HEALTHCHECK."""
    return {"status": "ok"}
