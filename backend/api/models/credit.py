from __future__ import annotations

from pydantic import BaseModel, Field, validator
from typing import List, Literal
from datetime import datetime
import random


class CreditScore(BaseModel):
    score: int = Field(ge=0, le=999)
    band: str
    last_refreshed: str  # YYYY-MM-DD


class CreditInsight(BaseModel):
    factor: str
    value: str
    recommendation: str


class CreditSimulationRequest(BaseModel):
    actions: List[str]

    @validator('actions', each_item=True)
    def validate_action(cls, v):  # noqa: N805
        allowed = {"pay_500", "reduce_utilisation", "close_oldest", "add_new_line"}
        if v not in allowed:
            raise ValueError("invalid action")
        return v


class CreditSimulationResult(BaseModel):
    projected_score: int
    band: str


def today() -> str:
    return datetime.utcnow().strftime('%Y-%m-%d')


class CRAStubTransUnion:
    def __init__(self) -> None:
        # seed with a realistic UK value
        self._score = random.randint(650, 780)

    def get_score(self) -> CreditScore:
        return CreditScore(score=self._score, band=band_for(self._score), last_refreshed=today())

    def get_insights(self) -> List[CreditInsight]:
        util = random.randint(20, 65)
        pay_hist = random.randint(95, 100)
        return [
            CreditInsight(factor="utilisation", value=f"{util}%", recommendation="Reduce below 30%"),
            CreditInsight(factor="payment_history", value=f"{pay_hist}%", recommendation="Maintain on-time payments"),
            CreditInsight(factor="length_of_history", value="5y 4m", recommendation="Keep older accounts open"),
            CreditInsight(factor="enquiries", value="1 in 6m", recommendation="Limit new applications"),
            CreditInsight(factor="mix", value="Cards, Loan", recommendation="Diversify responsibly"),
        ]

    def simulate(self, actions: List[str]) -> CreditSimulationResult:
        s = self._score
        for a in actions:
            if a == "pay_500":
                s += 12
            elif a == "reduce_utilisation":
                s += 22
            elif a == "close_oldest":
                s -= 18
            elif a == "add_new_line":
                s -= 8
        s = max(0, min(999, s))
        self._score = s
        return CreditSimulationResult(projected_score=s, band=band_for(s))


def band_for(score: int) -> str:
    if score >= 880:
        return "Excellent"
    if score >= 740:
        return "Very Good"
    if score >= 670:
        return "Good"
    if score >= 560:
        return "Fair"
    return "Poor"

