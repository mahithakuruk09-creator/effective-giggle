from fastapi import APIRouter, HTTPException
from .models.credit import CRAStubTransUnion, CreditScore, CreditInsight, CreditSimulationRequest, CreditSimulationResult

router = APIRouter(prefix="/credit", tags=["credit"])

CRA = CRAStubTransUnion()


@router.get("/score", response_model=CreditScore)
def get_score():
    return CRA.get_score()


@router.get("/insights", response_model=list[CreditInsight])
def get_insights():
    return CRA.get_insights()


@router.post("/simulate", response_model=CreditSimulationResult)
def simulate(payload: CreditSimulationRequest):
    try:
        return CRA.simulate(payload.actions)
    except ValueError as e:
        raise HTTPException(status_code=422, detail=str(e))

