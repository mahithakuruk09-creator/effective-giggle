from fastapi import FastAPI
from fastapi.testclient import TestClient
from backend.api.push import router


def app() -> FastAPI:
    a = FastAPI(); a.include_router(router); return a


def test_push_register_and_topics():
    a = app(); c = TestClient(a)
    r = c.post('/push/token', json={'token': 'stub-device'})
    assert r.status_code == 200
    s = c.post('/push/subscribe', json={'token': 'stub-device', 'topic': 'rewards'})
    assert s.status_code == 200
    g = c.get('/push/topics', params={'token': 'stub-device'})
    assert g.status_code == 200
    assert 'rewards' in g.json()['topics']
    u = c.post('/push/unsubscribe', json={'token': 'stub-device', 'topic': 'rewards'})
    assert u.status_code == 200

