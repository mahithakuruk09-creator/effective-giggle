from fastapi.testclient import TestClient
from backend.api.main import app

def test_pay_bill():
    client = TestClient(app)
    resp = client.post('/pay-bill', json={'biller_id': 'cc1', 'amount': 200, 'source_account': 'HSBC-1234'})
    assert resp.status_code == 200
    data = resp.json()
    assert data['status'] == 'success'
    assert data['pintos_earned'] == 100
