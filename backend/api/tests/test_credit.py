from fastapi import FastAPI
from fastapi.testclient import TestClient
from backend.api.credit import router


def create_app() -> FastAPI:
    app = FastAPI()
    app.include_router(router)
    return app


def test_credit_endpoints():
    app = create_app()
    c = TestClient(app)

    rs = c.get('/credit/score')
    assert rs.status_code == 200
    body = rs.json()
    assert 0 <= body['score'] <= 999
    assert isinstance(body['band'], str)

    ri = c.get('/credit/insights')
    assert ri.status_code == 200
    insights = ri.json()
    assert isinstance(insights, list) and len(insights) > 0
    assert 'factor' in insights[0]

    rsim = c.post('/credit/simulate', json={'actions': ['pay_500', 'reduce_utilisation']})
    assert rsim.status_code == 200
    sim = rsim.json()
    assert 0 <= sim['projected_score'] <= 999
    assert isinstance(sim['band'], str)

    # invalid action
    rbad = c.post('/credit/simulate', json={'actions': ['nope']})
    assert rbad.status_code == 422

