from fastapi import FastAPI
from fastapi.testclient import TestClient
from backend.api.loans import router


def create_app() -> FastAPI:
    app = FastAPI()
    app.include_router(router)
    return app


def test_loans_offers_and_apply():
    app = create_app()
    c = TestClient(app)
    r = c.get('/loans/offers')
    assert r.status_code == 200
    offers = r.json()
    assert isinstance(offers, list) and len(offers) > 0

    a = c.post('/loans/apply', json={"amount": 3000, "term_months": 24, "purpose": "Consolidation"})
    assert a.status_code == 200
    body = a.json()
    assert body["status"] in {"approved", "pending"}
    loan_id = body["id"]
    g = c.get(f'/loans/{loan_id}')
    assert g.status_code == 200
    got = g.json()
    assert got['application']['amount'] == 3000
