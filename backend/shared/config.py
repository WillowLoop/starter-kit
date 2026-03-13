import warnings

from pydantic import Field, ValidationInfo, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict

_LOCAL_ORIGINS = [f"http://localhost:{p}" for p in range(3000, 3016)]


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    app_env: str = "development"
    app_debug: bool = False
    postgres_port: int | None = None
    database_url: str
    redis_url: str | None = None
    cors_origins: list[str] = _LOCAL_ORIGINS
    secret_key: str = Field(min_length=1)
    log_level: str = "INFO"
    sentry_dsn: str | None = None
    sentry_traces_sample_rate: float = Field(default=0.0, ge=0.0, le=1.0)
    sentry_environment: str | None = None
    rate_limit_default: str = "100/minute"

    @field_validator("database_url", mode="after")
    @classmethod
    def check_port_consistency(cls, v: str, info: ValidationInfo) -> str:
        port = info.data.get("postgres_port")
        if port and f":{port}/" not in v and f":{port}?" not in v:
            warnings.warn(
                f"DATABASE_URL port does not match POSTGRES_PORT={port}. "
                "Update DATABASE_URL or POSTGRES_PORT to match.",
                stacklevel=2,
            )
        return v

    @field_validator("cors_origins", mode="before")
    @classmethod
    def parse_cors_origins(cls, v: str | list[str]) -> list[str]:
        if isinstance(v, str):
            return [origin.strip() for origin in v.split(",") if origin.strip()]
        return v

    @property
    def is_development(self) -> bool:
        return self.app_env == "development"

    @property
    def is_testing(self) -> bool:
        return self.app_env == "testing"


settings = Settings()
