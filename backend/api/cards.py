from fastapi import APIRouter, HTTPException
from .models.card import InMemoryCards, Card, Transaction, CreditCardOffer, CreditCardApplication

router = APIRouter(prefix="/cards", tags=["cards"])

STORE = InMemoryCards()


@router.get("", response_model=list[Card])
def list_cards():
    return list(STORE.cards.values())


@router.post("/add")
def add_card(payload: dict):
    name = payload.get("name")
    last4 = payload.get("last4")
    if not name or not last4:
        raise HTTPException(status_code=422, detail="name and last4 required")
    c = STORE.add(name, last4)
    return {"status": "success", "id": c.id}


@router.post("/freeze")
def freeze_card(payload: dict):
    cid = payload.get("id")
    frozen = payload.get("frozen")
    if cid not in STORE.cards:
        raise HTTPException(status_code=404, detail="not found")
    c = STORE.freeze(cid, bool(frozen))
    return {"status": "updated", "frozen": c.frozen}


@router.get("/{cid}/transactions", response_model=list[Transaction])
def card_transactions(cid: str):
    if cid not in STORE.tx:
        return []
    return STORE.tx[cid]

# ---- Credit card offers & applications ----

@router.get("/offers", response_model=list[CreditCardOffer])
def card_offers():
    return STORE.offers()


@router.post("/apply", response_model=CreditCardApplication)
def apply_card(payload: dict):
    offer_id = payload.get("offer_id")
    try:
        return STORE.apply_offer(user_id="u1", offer_id=offer_id)
    except KeyError:
        raise HTTPException(status_code=404, detail="offer not found")


@router.get("/applications/{app_id}", response_model=CreditCardApplication)
def get_card_application(app_id: str):
    try:
        return STORE.card_application(app_id)
    except KeyError:
        raise HTTPException(status_code=404, detail="not found")
