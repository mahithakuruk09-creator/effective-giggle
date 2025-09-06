from __future__ import annotations

from pydantic import BaseModel
from typing import Dict, List
from datetime import datetime


class MockAccount(BaseModel):
    sort_code: str
    account_number: str


class MockCard(BaseModel):
    id: str
    name: str
    last4: str
    network: str  # VISA/MC
    type: str  # virtual/physical
    frozen: bool = False


class MockTransaction(BaseModel):
    id: str
    card_id: str
    date: str
    merchant: str
    amount: int  # signed GBP


class WalletBalances(BaseModel):
    GBP: int
    EUR: int
    USD: int


class MockFinanceStore:
    def __init__(self) -> None:
        self.account = MockAccount(sort_code="12-34-56", account_number="12345678")
        self.cards: Dict[str, MockCard] = {
            "mc_virtual": MockCard(id="mc_virtual", name="Scredex Virtual", last4="4433", network="Mastercard", type="virtual", frozen=False),
            "mc_physical": MockCard(id="mc_physical", name="Scredex Metal", last4="8765", network="Mastercard", type="physical", frozen=False),
        }
        self.txs: Dict[str, List[MockTransaction]] = {
            "mc_virtual": [
                MockTransaction(id="tx1", card_id="mc_virtual", date=_today(), merchant="Tesco", amount=-12),
                MockTransaction(id="tx2", card_id="mc_virtual", date=_today(), merchant="Pret", amount=-5),
            ],
            "mc_physical": [
                MockTransaction(id="tx3", card_id="mc_physical", date=_today(), merchant="Apple", amount=-129),
            ],
        }
        self.wallet = WalletBalances(GBP=1285, EUR=320, USD=40)

    def freeze(self, card_id: str, frozen: bool) -> MockCard:
        if card_id not in self.cards:
            raise KeyError("card not found")
        c = self.cards[card_id]
        c = c.copy(update={"frozen": frozen})
        self.cards[card_id] = c
        return c

    def txs_for(self, card_id: str) -> List[MockTransaction]:
        return list(self.txs.get(card_id, []))

    def topup(self, currency: str, amount: int) -> WalletBalances:
        if amount <= 0:
            raise ValueError("amount must be positive")
        if currency not in {"GBP", "EUR", "USD"}:
            raise ValueError("invalid currency")
        current = self.wallet.dict()
        current[currency] += amount
        self.wallet = WalletBalances(**current)
        return self.wallet


def _today() -> str:
    return datetime.utcnow().strftime("%Y-%m-%d")

