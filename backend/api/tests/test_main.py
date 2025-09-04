from fastapi.testclient import TestClient
from backend.api.main import app

client = TestClient(app)

def test_root():
    r = client.get('/')
    assert r.status_code == 200
    assert r.json() == {'message': 'Hello from Scredex API'}
