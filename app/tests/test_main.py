from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"

def test_shorten_url():
    response = client.post("/shorten", json={"url": "https://google.com"})
    assert response.status_code == 200
    assert "short_code" in response.json()

def test_resolve_url():
    # First shorten
    shorten = client.post("/shorten", json={"url": "https://github.com"})
    code = shorten.json()["short_code"]
    # Then resolve
    resolve = client.get(f"/resolve/{code}")
    assert resolve.status_code == 200
    assert resolve.json()["original_url"] == "https://github.com"

def test_resolve_missing_code():
    response = client.get("/resolve/999999")
    assert response.status_code == 404