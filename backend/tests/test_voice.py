from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_voice_greeting_default_english():
    response = client.get("/api/v1/voice/greeting")
    assert response.status_code == 200
    assert response.headers["content-type"] == "audio/mpeg"
    assert len(response.content) > 0


def test_voice_greeting_tamil():
    response = client.get("/api/v1/voice/greeting?lang=ta")
    assert response.status_code == 200
    assert response.headers["content-type"] == "audio/mpeg"
    assert len(response.content) > 0


def test_voice_greeting_fallback():
    response = client.get("/api/v1/voice/greeting?lang=unsupported_lang")
    assert response.status_code == 200
    assert response.headers["content-type"] == "audio/mpeg"
    assert len(response.content) > 0
