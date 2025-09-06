from __future__ import annotations

from pydantic import BaseModel
from typing import Literal, List

TxnType = Literal["earn", "redeem"]


class PintoTransaction(BaseModel):
  id: str
  date: str  # YYYY-MM-DD
  type: TxnType
  source: str
  amount: int  # positive for earn, negative for redeem


class PintoBalance(BaseModel):
  balance: int


class PintoEngine:
  def __init__(self, starting_balance: int = 1500) -> None:
    self.balance = starting_balance
    self.ledger: List[PintoTransaction] = []

  def earn(self, source: str, amount: int) -> PintoTransaction:
    self.balance += amount
    t = PintoTransaction(id=f"t{len(self.ledger)+1}", date=_today(), type="earn", source=source, amount=amount)
    self.ledger.append(t)
    return t

  def redeem(self, source: str, price: int) -> PintoTransaction:
    if self.balance < price:
      raise ValueError("insufficient")
    self.balance -= price
    t = PintoTransaction(id=f"t{len(self.ledger)+1}", date=_today(), type="redeem", source=source, amount=-price)
    self.ledger.append(t)
    return t


def _today() -> str:
  from datetime import datetime
  return datetime.utcnow().strftime('%Y-%m-%d')

