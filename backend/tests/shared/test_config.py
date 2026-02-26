from shared.config import settings


def test_settings_loaded() -> None:
    assert settings.app_env == "testing"


def test_settings_is_testing() -> None:
    assert settings.is_testing is True
    assert settings.is_development is False


def test_settings_has_secret_key() -> None:
    assert settings.secret_key == "test-secret-key-do-not-use-in-production"


def test_cors_origins_is_list() -> None:
    assert isinstance(settings.cors_origins, list)
