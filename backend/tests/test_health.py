from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_root_endpoint():
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert "name" in data
    assert data["docs"] == "/docs"


def test_health_endpoint():
    response = client.get("/api/v1/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] in ["ok", "degraded"]
    assert "components" in data
    assert "database" in data["components"]


def test_liveness_endpoint():
    response = client.get("/api/v1/health/liveness")
    assert response.status_code == 200
    assert response.json()["status"] == "alive"


def test_readiness_endpoint_healthy():
    response = client.get("/api/v1/health/readiness")
    assert response.status_code == 200
    assert response.json()["status"] == "ready"


def test_readiness_and_health_fail_when_db_down(monkeypatch):
    """Verifies that health and readiness fail with 503 Service Unavailable when the database is unreachable."""
    from sqlalchemy.exc import OperationalError

    def failing_execute(*args, **kwargs):
        raise OperationalError("Connection refused", {}, None)

    monkeypatch.setattr("sqlalchemy.orm.Session.execute", failing_execute)

    readiness_resp = client.get("/api/v1/health/readiness")
    assert readiness_resp.status_code == 503
    assert readiness_resp.json()["status"] == "not_ready"

    health_resp = client.get("/api/v1/health")
    assert health_resp.status_code == 503
    assert health_resp.json()["status"] == "degraded"

