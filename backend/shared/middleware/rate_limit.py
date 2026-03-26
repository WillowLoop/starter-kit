from slowapi import Limiter
from slowapi.util import get_remote_address
from starlette.requests import Request
from starlette.responses import JSONResponse

from shared.config import settings

# Note: get_remote_address uses request.client.host.
# Behind a reverse proxy (e.g., Caddy, Nginx), configure X-Forwarded-For trust
# at the proxy level to ensure correct client IP detection.

limiter = Limiter(
    key_func=get_remote_address,
    default_limits=[settings.rate_limit_default],
)


async def rate_limit_exceeded_handler(request: Request, exc: Exception) -> JSONResponse:
    return JSONResponse(
        status_code=429,
        content={"detail": "Rate limit exceeded. Try again later."},
    )
