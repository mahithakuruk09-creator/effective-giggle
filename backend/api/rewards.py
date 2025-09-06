from fastapi import APIRouter, HTTPException
from .models.reward import PintoEngine, PintoTransaction, PintoBalance
from .models.store_item import InMemoryStore

router = APIRouter(prefix="/rewards", tags=["rewards"])

ENGINE = PintoEngine(starting_balance=1800)
STORE = InMemoryStore()


@router.get("/ledger", response_model=list[PintoTransaction])
def get_ledger():
  return ENGINE.ledger


@router.get("/balance", response_model=PintoBalance)
def get_balance():
  return PintoBalance(balance=ENGINE.balance)


@router.post("/redeem")
def redeem(payload: dict):
  item_id = payload.get("item_id")
  if not item_id:
    raise HTTPException(status_code=422, detail="item_id required")
  item = STORE.get(item_id)
  if not item:
    raise HTTPException(status_code=404, detail="item not found")
  try:
    ENGINE.redeem(item.title, item.price)
  except ValueError:
    raise HTTPException(status_code=400, detail="insufficient balance")
  return {"status": "success", "new_balance": ENGINE.balance}

