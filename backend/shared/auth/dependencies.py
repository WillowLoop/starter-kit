from fastapi import Depends
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

security = HTTPBearer()


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
) -> None:
    """Placeholder auth dependency. Replace with JWT validation when implementing auth."""
    raise NotImplementedError(
        f"JWT auth not yet implemented (token: {credentials.credentials[:8]}...)"
    )
