from __future__ import annotations

from pydantic import BaseModel
from typing import Dict, List
from datetime import datetime


class Card(BaseModel):
    id: str
    name: str
    last4: str
    balance: int
    is_default: bool
    frozen: bool


class Transaction(BaseModel):
    id: str
    date: str
    merchant: str
    amount: int


class InMemoryCards:
    def __init__(self) -> None:
        self.cards: Dict[str, Card] = {
            'c1': Card(id='c1', name='Scredex Metal', last4='4242', balance=1235, is_default=True, frozen=False),
            'c2': Card(id='c2', name='Scredex Lite', last4='1881', balance=230, is_default=False, frozen=False),
        }
        self.tx: Dict[str, List[Transaction]] = {
            'c1': [Transaction(id='t1', date=_today(), merchant='Apple', amount=-123), Transaction(id='t2', date=_today(), merchant='Pret', amount=-5)]
        }
        # Credit card offers & applications
        self.card_offers: Dict[str, CreditCardOffer] = {
            'off_platinum': CreditCardOffer(id='off_platinum', name='Platinum Cashback', apr=19.9, limit=8000, annual_fee=95, perks=['1.5% cashback', 'Airport lounge']),
            'off_rewards': CreditCardOffer(id='off_rewards', name='Rewards Everyday', apr=21.9, limit=4000, annual_fee=0, perks=['0.5% cashback', 'No annual fee']),
        }
        self.card_apps: Dict[str, CreditCardApplication] = {}
        self._seq = 1

    def freeze(self, card_id: str, frozen: bool) -> Card:
        c = self.cards[card_id]
        c = c.copy(update={'frozen': frozen})
        self.cards[card_id] = c
        return c

    def add(self, name: str, last4: str) -> Card:
        cid = f"c{len(self.cards)+1}"
        c = Card(id=cid, name=name, last4=last4, balance=0, is_default=False, frozen=False)
        self.cards[cid] = c
        self.tx[cid] = []
        return c

    # --- Credit card offers & applications ---
    def offers(self) -> List['CreditCardOffer']:
        return list(self.card_offers.values())

    def apply_offer(self, user_id: str, offer_id: str) -> 'CreditCardApplication':
        if offer_id not in self.card_offers:
            raise KeyError('offer not found')
        app_id = f"cc_{self._seq:03d}"; self._seq += 1
        offer = self.card_offers[offer_id]
        # stub: approve if limit <= 8000
        decision = 'eligible' if offer.limit <= 8000 else 'referred'
        status = 'submitted'
        app = CreditCardApplication(id=app_id, user_id=user_id, offer_id=offer_id, status=status, decision=decision)
        self.card_apps[app_id] = app
        return app

    def card_application(self, app_id: str) -> 'CreditCardApplication':
        return self.card_apps[app_id]


# --- Credit card offer and application models ---
class CreditCardOffer(BaseModel):
    id: str
    name: str
    apr: float
    limit: int
    annual_fee: int
    perks: List[str]


class CreditCardApplication(BaseModel):
    id: str
    user_id: str
    offer_id: str
    status: str  # submitted -> under_review -> approved -> issued
    decision: str  # eligible/ineligible/referred


def _today() -> str:
    return datetime.utcnow().strftime('%Y-%m-%d')
