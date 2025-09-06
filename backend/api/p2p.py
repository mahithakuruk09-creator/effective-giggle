from fastapi import APIRouter, HTTPException
from .models.p2p import InMemoryP2P, P2PPool

router = APIRouter(prefix="/p2p", tags=["p2p"])

STORE = InMemoryP2P()


@router.get("/pools", response_model=list[P2PPool])
def pools():
    return list(STORE.pools.values())


@router.post("/invest")
def invest(payload: dict):
    pool_id = payload.get("pool_id")
    amount = payload.get("amount")
    if pool_id not in STORE.pools:
        raise HTTPException(status_code=404, detail="pool not found")
    if not isinstance(amount, int) or amount <= 0:
        raise HTTPException(status_code=422, detail="invalid amount")
    inv = STORE.invest(pool_id, amount)
    return {"status": "success", "investment_id": inv.id}


@router.post("/borrow")
def borrow(payload: dict):
    try:
        amount = int(payload.get("amount"))
        term = int(payload.get("term_months"))
        purpose = str(payload.get("purpose"))
    except Exception as e:
        raise HTTPException(status_code=422, detail=str(e))
    req = STORE.borrow(amount, term, purpose)
    return {"status": "pending", "request_id": req.id}


@router.get("/portfolio")
def portfolio():
    total = sum(iv.amount for iv in STORE.investments.values())
    return {"invested": total, "expected_return": round(total * 0.071, 2)}


@router.post("/repay")
def repay(payload: dict):
    amount = payload.get("amount")
    if not isinstance(amount, int) or amount <= 0:
        raise HTTPException(status_code=422, detail="invalid amount")
    # stub: acknowledge
    return {"status": "received", "amount": amount}
