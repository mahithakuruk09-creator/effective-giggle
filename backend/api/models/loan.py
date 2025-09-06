from __future__ import annotations

from pydantic import BaseModel, Field
from typing import List


class LoanOffer(BaseModel):
    id: str
    apr: float
    amount: int
    term_months: int
    monthly_repayment: int


class LoanApplication(BaseModel):
    amount: int = Field(gt=0)
    term_months: int = Field(gt=0)
    purpose: str


def sample_offers() -> List[LoanOffer]:
    return [
        LoanOffer(id="lo_001", apr=12.9, amount=5000, term_months=24, monthly_repayment=237),
        LoanOffer(id="lo_002", apr=8.5, amount=8000, term_months=36, monthly_repayment=252),
        LoanOffer(id="lo_003", apr=17.9, amount=2000, term_months=12, monthly_repayment=185),
    ]

