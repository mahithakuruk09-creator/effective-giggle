from fastapi import FastAPI
from fastapi.testclient import TestClient
from backend.api.shop import router


def app() -> FastAPI:
    app = FastAPI()
    app.include_router(router)
    return app


def test_products_cart_checkout_rewards():
    a = app()
    c = TestClient(a)

    # products
    r = c.get('/shop/products?category=Apparel')
    assert r.status_code == 200
    items = r.json()
    assert len(items) >= 1
    pid = items[0]['id']

    # add to cart
    add = c.post('/shop/cart/items', json={'product_id': pid, 'qty': 2})
    assert add.status_code == 200
    ci = add.json()['id']

    # list cart
    lc = c.get('/shop/cart')
    assert lc.status_code == 200
    assert len(lc.json()) >= 1

    # update
    up = c.put(f'/shop/cart/items/{ci}', json={'qty': 1})
    assert up.status_code == 200

    # rewards before
    rb = c.get('/shop/rewards')
    bal_before = rb.json()['balance']

    # checkout (no redeem)
    co = c.post('/shop/orders/checkout', json={'redeem': 0})
    assert co.status_code == 200
    total = co.json()['total']

    # rewards after: + total
    ra = c.get('/shop/rewards')
    bal_after = ra.json()['balance']
    assert bal_after - bal_before == total

    # wishlist
    w = c.post(f'/shop/wishlist/{pid}')
    assert w.status_code == 200
    wl = c.get('/shop/wishlist').json()['items']
    assert pid in wl
    d = c.delete(f'/shop/wishlist/{pid}')
    assert d.status_code == 200

