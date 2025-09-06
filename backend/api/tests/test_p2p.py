from fastapi import FastAPI
from fastapi.testclient import TestClient
from backend.api.p2p import router


def create_app() -> FastAPI:
    app = FastAPI()
    app.include_router(router)
    return app


def test_p2p_pools_and_invest_borrow():
    app = create_app()
    c = TestClient(app)

    r = c.get('/p2p/pools')
    assert r.status_code == 200
    pools = r.json()
    assert len(pools) >= 1
    pid = pools[0]['id']

    inv = c.post('/p2p/invest', json={'pool_id': pid, 'amount': 500})
    assert inv.status_code == 200
    assert inv.json()['status'] == 'success'

  br = c.post('/p2p/borrow', json={'amount': 1000, 'term_months': 12, 'purpose': 'Home'})
  assert br.status_code == 200
  assert br.json()['status'] == 'pending'

  # portfolio
  pf = c.get('/p2p/portfolio')
  assert pf.status_code == 200
  assert 'invested' in pf.json()

  # repay stub
  rp = c.post('/p2p/repay', json={'amount': 50})
  assert rp.status_code == 200
  assert rp.json()['status'] == 'received'
