from httpx import AsyncClient


async def test_health_returns_200(client: AsyncClient) -> None:
    response = await client.get("/health")
    assert response.status_code == 200


async def test_health_contains_expected_fields(client: AsyncClient) -> None:
    response = await client.get("/health")
    data = response.json()
    assert "status" in data
    assert "database" in data
    assert "redis" in data
    assert "version" in data


async def test_health_database_up(client: AsyncClient) -> None:
    response = await client.get("/health")
    data = response.json()
    assert data["database"] == "up"


async def test_health_redis_skipped_when_not_configured(client: AsyncClient) -> None:
    response = await client.get("/health")
    data = response.json()
    assert data["redis"] == "skipped"


async def test_liveness_returns_200(client: AsyncClient) -> None:
    """Verify /health/live returns 200 with ok status."""
    response = await client.get("/health/live")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_liveness_endpoint_has_no_fastapi_dependencies() -> None:
    """Verify /health/live injects no FastAPI Depends() parameters."""
    import inspect
    import typing

    from fastapi import params as fastapi_params

    from features.health.router import health_live

    sig = inspect.signature(health_live)
    for name, param in sig.parameters.items():
        # Check directe Depends() default
        if isinstance(param.default, fastapi_params.Depends):
            raise AssertionError(f"Parameter '{name}' uses Depends()")
        # Check Annotated[T, Depends()] patroon
        ann = param.annotation
        if typing.get_origin(ann) is typing.Annotated:
            for meta in typing.get_args(ann)[1:]:
                if isinstance(meta, fastapi_params.Depends):
                    raise AssertionError(f"Parameter '{name}' uses Annotated Depends()")
