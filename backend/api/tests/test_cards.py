from fastapi import FastAPI
from fastapi.testclient import TestClient
from backend.api.cards import router


def create_app() -> FastAPI:
    app = FastAPI()
    app.include_router(router)
    return app


def test_cards_list_freeze_tx():
    app = create_app()
    c = TestClient(app)

    r = c.get('/cards')
    assert r.status_code == 200
    cards = r.json()
    assert len(cards) >= 1
    cid = cards[0]['id']

    f = c.post('/cards/freeze', json={'id': cid, 'frozen': True})
    assert f.status_code == 200
    assert f.json()['status'] == 'updated'

    t = c.get(f'/cards/{cid}/transactions')
    assert t.status_code == 200
    assert isinstance(t.json(), list)

def test_credit_card_offers_and_apply():
    app = create_app()
    c = TestClient(app)
    o = c.get('/cards/offers')
    assert o.status_code == 200
    offers = o.json()
    assert len(offers) >= 2
    off_id = offers[0]['id']
    a = c.post('/cards/apply', json={'offer_id': off_id})
    assert a.status_code == 200
    app_id = a.json()['id']
    g = c.get(f'/cards/applications/{app_id}')
    assert g.status_code == 200
    assert g.json()['offer_id'] == off_id
