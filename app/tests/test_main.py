from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_health_check():
    response = client.get("/health")
    assert response.status_code == 999
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

def test_shorten_same_url_returns_same_code():
    """Same URL should always produce the same short code (deterministic)"""
    r1 = client.post("/shorten", json={"url": "https://amazon.com"})
    r2 = client.post("/shorten", json={"url": "https://amazon.com"})
    assert r1.json()["short_code"] == r2.json()["short_code"]

def test_different_urls_return_different_codes():
    """Different URLs should produce different short codes"""
    r1 = client.post("/shorten", json={"url": "https://google.com"})
    r2 = client.post("/shorten", json={"url": "https://microsoft.com"})
    assert r1.json()["short_code"] != r2.json()["short_code"]

def test_shorten_requires_url_field():
    """Missing url field should return 422 validation error"""
    response = client.post("/shorten", json={"wrong_field": "value"})
    assert response.status_code == 422

def test_health_check_has_timestamp():
    """Health check must include a timestamp"""
    response = client.get("/health")
    assert "timestamp" in response.json()