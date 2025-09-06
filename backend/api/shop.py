from fastapi import APIRouter, HTTPException, Query
from typing import Optional
from .models.shop import InMemoryShop, Product, CartItem, Order, RewardAccount
try:
    from .notifications import router as _notif_router  # noqa: F401
    from .models.insights import NotificationItem
    from .notifications import STORE as NOTIF_STORE
except Exception:  # pragma: no cover
    NOTIF_STORE = None

# Optional integration with PintoEngine (Phase 6). If available, mirror balance updates
try:
    from .rewards import ENGINE as PINTO_ENGINE  # type: ignore
except Exception:  # pragma: no cover - optional
    PINTO_ENGINE = None


router = APIRouter(prefix="/shop", tags=["shop"])
STORE = InMemoryShop()
USER = "u1"  # stub user


@router.get("/products", response_model=list[Product])
def list_products(category: Optional[str] = Query(default=None), search: Optional[str] = Query(default=None)):
    return STORE.list_products(category, search)


@router.get("/products/{pid}", response_model=Product)
def get_product(pid: str):
    p = STORE.get_product(pid)
    if not p:
        raise HTTPException(status_code=404, detail="not found")
    return p


@router.post("/cart/items", response_model=CartItem)
def add_cart(payload: dict):
    try:
        return STORE.add_to_cart(USER, payload.get("product_id"), int(payload.get("qty", 1)))
    except KeyError:
        raise HTTPException(status_code=404, detail="product not found")
    except ValueError as e:
        raise HTTPException(status_code=422, detail=str(e))


@router.get("/cart", response_model=list[CartItem])
def list_cart():
    return STORE.list_cart(USER)


@router.put("/cart/items/{cid}", response_model=CartItem)
def update_cart(cid: str, payload: dict):
    qty = int(payload.get("qty", 0))
    try:
        return STORE.update_cart(USER, cid, qty)
    except KeyError:
        raise HTTPException(status_code=404, detail="cart item not found")
    except ValueError:
        # deleted
        raise HTTPException(status_code=410, detail="deleted")


@router.delete("/cart/items/{cid}")
def delete_cart(cid: str):
    STORE.delete_cart_item(USER, cid)
    return {"status": "deleted"}


@router.post("/orders/checkout", response_model=Order)
def checkout(payload: dict):
    redeem = int(payload.get("redeem", 0))
    try:
        order = STORE.checkout(USER, redeem)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    # sync PintoEngine balance if present
    if PINTO_ENGINE is not None:  # pragma: no cover - optional integration
        # reflect STORE.rewards -> PINTO_ENGINE.balance for shared UX
        acc = STORE.rewards_for(USER)
        PINTO_ENGINE.balance = acc.balance
    # create reward notification (integration hook)
    if NOTIF_STORE is not None:  # pragma: no cover
        try:
            NOTIF_STORE.notifications[f"shop_{order.id}"] = NotificationItem(
                id=f"shop_{order.id}", type="rewards", title="Pintos earned",
                body=f"You earned {order.total} Pintos from your purchase.", cta="Redeem", status="unread",
            )
        except Exception:
            pass
    return order


@router.get("/orders", response_model=list[Order])
def list_orders():
    return list(STORE.orders.values())


@router.get("/wishlist")
def get_wishlist():
    return {"items": STORE.wishlists.get(USER, [])}


@router.post("/wishlist/{pid}")
def add_wishlist(pid: str):
    if not STORE.get_product(pid):
        raise HTTPException(status_code=404, detail="not found")
    wl = STORE.wishlists.setdefault(USER, [])
    if pid not in wl:
        wl.append(pid)
    return {"status": "added"}


@router.delete("/wishlist/{pid}")
def del_wishlist(pid: str):
    wl = STORE.wishlists.setdefault(USER, [])
    if pid in wl:
        wl.remove(pid)
    return {"status": "deleted"}


@router.get("/rewards", response_model=RewardAccount)
def get_rewards():
    return STORE.rewards_for(USER)
