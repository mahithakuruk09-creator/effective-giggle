from fastapi import FastAPI
from fastapi.testclient import TestClient
from backend.api.autopay import router


def create_app() -> FastAPI:
    app = FastAPI()
    app.include_router(router)
    return app


def test_autopay_crud():
    app = create_app()
    client = TestClient(app)

    # list initially empty
    r = client.get("/autopay")
    assert r.status_code == 200
    assert r.json() == []

    # add
    payload = {
        "biller_id": "b123",
        "type": "full",
        "cap": 500,
        "pre_alert_days": 2,
        "enabled": True,
    }
    r = client.post("/autopay/add", json=payload)
    assert r.status_code == 200
    body = r.json()
    assert body["status"] == "success"
    ap_id = body["autopay_id"]

    # list has one
    r = client.get("/autopay")
    assert r.status_code == 200
    items = r.json()
    assert len(items) == 1
    assert items[0]["autopay_id"] == ap_id

    # update
    r = client.patch(f"/autopay/{ap_id}", json={
        "type": "minimum",
        "cap": 200,
        "pre_alert_days": 1,
        "enabled": False,
    })
    assert r.status_code == 200
    assert r.json()["status"] == "updated"

    # toggle
    r = client.post(f"/autopay/{ap_id}/toggle", json={"enabled": True})
    assert r.status_code == 200
    assert r.json() == {"autopay_id": ap_id, "enabled": True}

    # delete
    r = client.delete(f"/autopay/{ap_id}")
    assert r.status_code == 200
    assert r.json()["status"] == "deleted"

