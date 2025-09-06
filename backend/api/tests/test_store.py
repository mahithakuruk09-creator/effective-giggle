from fastapi import FastAPI
from fastapi.testclient import TestClient
from backend.api.store import router


def create_app() -> FastAPI:
  app = FastAPI()
  app.include_router(router)
  return app


def test_store_list_and_detail():
  app = create_app()
  c = TestClient(app)
  r = c.get('/store')
  assert r.status_code == 200
  items = r.json()
  assert len(items) > 0
  first = items[0]
  rid = first['id']
  r2 = c.get(f'/store/{rid}')
  assert r2.status_code == 200
  assert r2.json()['id'] == rid

