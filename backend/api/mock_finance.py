from fastapi import APIRouter, HTTPException
from .models.mock_finance import MockFinanceStore, MockAccount, MockCard, MockTransaction, WalletBalances

router = APIRouter(prefix="/mock", tags=["mock_finance"]) 

STORE = MockFinanceStore()


@router.get("/account", response_model=MockAccount)
def get_account():
    return STORE.account


@router.get("/cards", response_model=list[MockCard])
def list_cards():
    return list(STORE.cards.values())


@router.post("/cards/{card_id}/freeze", response_model=MockCard)
def freeze(card_id: str, payload: dict):
    try:
        frozen = bool(payload.get("frozen"))
        return STORE.freeze(card_id, frozen)
    except KeyError:
        raise HTTPException(status_code=404, detail="card not found")


@router.get("/cards/{card_id}/transactions", response_model=list[MockTransaction])
def transactions(card_id: str):
    return STORE.txs_for(card_id)


@router.get("/wallet", response_model=WalletBalances)
def wallet():
    return STORE.wallet


@router.post("/wallet/topup", response_model=WalletBalances)
def topup(payload: dict):
    currency = payload.get("currency")
    amount = payload.get("amount")
    if not isinstance(amount, int):
        raise HTTPException(status_code=422, detail="amount must be int")
    try:
        return STORE.topup(currency, amount)
    except ValueError as e:
        raise HTTPException(status_code=422, detail=str(e))

