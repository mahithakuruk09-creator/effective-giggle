from fastapi import FastAPI
from fastapi.testclient import TestClient
from backend.api.rewards import router as rewards_router
from backend.api.store import router as store_router


def app_with_rewards() -> FastAPI:
  app = FastAPI()
  app.include_router(store_router)
  app.include_router(rewards_router)
  return app


def test_ledger_and_balance_and_redeem():
  app = app_with_rewards()
  c = TestClient(app)

  # balance returns integer
  r = c.get('/rewards/balance')
  assert r.status_code == 200
  assert isinstance(r.json()['balance'], int)

  # ledger returns list
  r = c.get('/rewards/ledger')
  assert r.status_code == 200
  assert isinstance(r.json(), list)

  # store list not empty
  rs = c.get('/store')
  assert rs.status_code == 200
  items = rs.json()
  assert len(items) > 0

  # redeem works
  item_id = items[0]['id']
  rr = c.post('/rewards/redeem', json={'item_id': item_id})
  assert rr.status_code == 200
  body = rr.json()
  assert body['status'] == 'success'
  assert isinstance(body['new_balance'], int)

  # invalid id fails
  rr2 = c.post('/rewards/redeem', json={'item_id': 'nope'})
  assert rr2.status_code == 404

