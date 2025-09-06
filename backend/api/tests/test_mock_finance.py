from fastapi import FastAPI
from fastapi.testclient import TestClient
from backend.api.mock_finance import router


def app() -> FastAPI:
    a = FastAPI()
    a.include_router(router)
    return a


def test_mock_finance_endpoints():
    a = app()
    c = TestClient(a)

    r = c.get('/mock/account')
    assert r.status_code == 200
    assert 'sort_code' in r.json()

    cards = c.get('/mock/cards')
    assert cards.status_code == 200
    cl = cards.json(); assert len(cl) >= 2
    cid = cl[0]['id']

    # freeze toggle
    f = c.post(f'/mock/cards/{cid}/freeze', json={'frozen': True})
    assert f.status_code == 200 and f.json()['frozen'] is True

    tx = c.get(f'/mock/cards/{cid}/transactions')
    assert tx.status_code == 200
    assert isinstance(tx.json(), list)

    w = c.get('/mock/wallet')
    assert w.status_code == 200
    b_before = w.json()['GBP']

    t = c.post('/mock/wallet/topup', json={'currency': 'GBP', 'amount': 10})
    assert t.status_code == 200
    assert t.json()['GBP'] == b_before + 10

