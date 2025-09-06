from __future__ import annotations

from pydantic import BaseModel, Field
from typing import List, Dict


class P2PPool(BaseModel):
    id: str
    risk: str  # Low/Med/High
    apr: float
    available: int


class Investment(BaseModel):
    id: str
    pool_id: str
    amount: int


class BorrowerRequest(BaseModel):
    id: str
    amount: int = Field(gt=0)
    term_months: int = Field(gt=0)
    purpose: str
    status: str  # pending/funded/active


class InMemoryP2P:
    def __init__(self) -> None:
        self.pools: Dict[str, P2PPool] = {
            'pf_low': P2PPool(id='pf_low', risk='Low', apr=4.2, available=20000),
            'pf_med': P2PPool(id='pf_med', risk='Med', apr=7.8, available=12000),
            'pf_high': P2PPool(id='pf_high', risk='High', apr=12.5, available=6000),
        }
        self.investments: Dict[str, Investment] = {}
        self.borrow_requests: Dict[str, BorrowerRequest] = {}
        self._seq = 1

    def invest(self, pool_id: str, amount: int) -> Investment:
        inv_id = f"iv_{self._seq:03d}"; self._seq += 1
        inv = Investment(id=inv_id, pool_id=pool_id, amount=amount)
        self.investments[inv_id] = inv
        p = self.pools[pool_id]
        self.pools[pool_id] = p.copy(update={'available': max(0, p.available - amount)})
        return inv

    def borrow(self, amount: int, term: int, purpose: str) -> BorrowerRequest:
        req_id = f"br_{self._seq:03d}"; self._seq += 1
        req = BorrowerRequest(id=req_id, amount=amount, term_months=term, purpose=purpose, status='pending')
        self.borrow_requests[req_id] = req
        return req

