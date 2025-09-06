from fastapi.testclient import TestClient
from backend.api.main import app

client = TestClient(app)

def test_get_dashboard():
    res = client.get('/dashboard')
    assert res.status_code == 200
    data = res.json()
    assert 'wallet_balance' in data
    assert 'linked_accounts' in data
    assert 'credit_score' in data
