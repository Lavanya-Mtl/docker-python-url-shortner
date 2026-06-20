from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import hashlib, time

app = FastAPI(title="URL Shortener", version="1.0.0")

# In-memory store (fine for portfolio purposes)
url_store: dict = {}

class URLRequest(BaseModel):
    url: str

@app.get("/health")
def health_check():
    return {"status": "healthy", "timestamp": time.time()}

@app.post("/shorten")
def shorten_url(request: URLRequest):
    short_code = hashlib.md5(request.url.encode()).hexdigest()[:6]
    url_store[short_code] = request.url
    return {"short_code": short_code, "original_url": request.url}

@app.get("/resolve/{short_code}")
def resolve_url(short_code: str):
    if short_code not in url_store:
        raise HTTPException(status_code=404, detail="Short code not found")
    return {"original_url": url_store[short_code]}

@app.get("/")
def root():
    return {"message": "URL Shortener API v3", "docs": "/docs"}