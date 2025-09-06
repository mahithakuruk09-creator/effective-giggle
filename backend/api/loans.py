from fastapi import APIRouter, HTTPException
from .models.loan import LoanApplication, LoanOffer, sample_offers
from pydantic import BaseModel
from typing import Dict, List

router = APIRouter(prefix="/loans", tags=["loans"])


@router.get("/offers", response_model=list[LoanOffer])
def offers():
    return sample_offers()


class Repayment(BaseModel):
    id: str
    due: str
    amount: int
    status: str  # due/paid


class LoanRecord(BaseModel):
    id: str
    application: LoanApplication
    status: str  # pending/approved/active/repaid
    apr: float
    repayments: List[Repayment] = []


STORE: Dict[str, LoanRecord] = {}
SEQ = 1


@router.post("/apply")
def apply(payload: LoanApplication):
    global SEQ
    eligible = payload.amount <= 15000 and payload.term_months <= 60
    loan_id = f"ln_{SEQ:03d}"; SEQ += 1
    apr = 12.9 if eligible else 21.9
    reps = [Repayment(id=f"r{i+1}", due=f"2025-{(i%12)+1:02d}-15", amount=int((payload.amount/payload.term_months)+10), status='due') for i in range(payload.term_months)]
    rec = LoanRecord(id=loan_id, application=payload, status='approved' if eligible else 'pending', apr=apr, repayments=reps)
    STORE[loan_id] = rec
    return {"id": loan_id, "status": rec.status, "apr": apr}


@router.get("/{loan_id}")
def get_loan(loan_id: str):
    rec = STORE.get(loan_id)
    if not rec:
        raise HTTPException(status_code=404, detail="not found")
    return rec
