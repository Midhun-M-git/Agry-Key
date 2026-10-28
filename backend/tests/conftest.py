"""Hermetic pytest configuration and disposable test database fixtures."""

import os
import tempfile
import pytest

# 1. Explicitly configure test settings before importing application singletons
# Controlled directly without setdefault to prevent inheritance of developer/production values.
os.environ["ENVIRONMENT"] = "test"
os.environ["ALLOW_MOCK_PAYMENT"] = "true"
os.environ["OTP_PROVIDER"] = "mock"
os.environ["SECRET_KEY"] = "hermetic-test-secret-key-32-chars-minimum-2026"
os.environ["SMS_API_KEY"] = "mock_test_key"
os.environ["HUGGINGFACE_API_KEY"] = "mock_hf_test_key"
os.environ["DL_FORECAST_SERVICE_URL"] = "https://agry-key-dl-space.hf.space/api/predict"
os.environ["DL_FORECAST_SERVICE_TOKEN"] = "secret-service-token-123"

# 2. Prevent ordinary tests from inheriting developer/production DATABASE_URL
_test_db_file = os.path.join(tempfile.gettempdir(), f"agry_key_disposable_{os.getpid()}.db")
os.environ["DATABASE_URL"] = f"sqlite:///{_test_db_file}"


@pytest.fixture(scope="session", autouse=True)
def hermetic_test_database_lifecycle():
    """Manage disposable test database lifecycle and clean up connections during teardown."""
    from app.core.database import Base, engine
    Base.metadata.create_all(bind=engine)
    yield
    engine.dispose()
    if os.path.exists(_test_db_file):
        try:
            os.remove(_test_db_file)
        except Exception:
            pass
