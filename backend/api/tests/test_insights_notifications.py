from fastapi import FastAPI
from fastapi.testclient import TestClient
from backend.api.insights import router as insights_router
from backend.api.notifications import router as notif_router


def app() -> FastAPI:
    a = FastAPI()
    a.include_router(insights_router)
    a.include_router(notif_router)
    return a


def test_insights_and_notifications():
    a = app()
    c = TestClient(a)

    si = c.get('/insights/spending')
    assert si.status_code == 200
    body = si.json()
    assert 'categories' in body and len(body['categories']) >= 1
    assert 'trends' in body and len(body['trends']) >= 1
    assert 'tips' in body and len(body['tips']) >= 1

    nf = c.get('/notifications')
    assert nf.status_code == 200
    items = nf.json(); assert len(items) >= 1
    nid = items[0]['id']
    act = c.post(f'/notifications/{nid}/action')
    assert act.status_code == 200
    assert act.json()['notification']['status'] == 'done'

