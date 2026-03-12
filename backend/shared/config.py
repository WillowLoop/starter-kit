from pydantic import Field, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    app_env: str = "development"
    app_debug: bool = False
    database_url: str
    redis_url: str | None = None
    cors_origins: list[str] = ["http://localhost:3000"]
    secret_key: str = Field(min_length=1)
    log_level: str = "INFO"
    sentry_dsn: str | None = None
    sentry_traces_sample_rate: float = Field(default=0.0, ge=0.0, le=1.0)
    sentry_environment: str | None = None

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
