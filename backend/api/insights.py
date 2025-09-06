from fastapi import APIRouter
from .models.insights import InsightsStore, SpendingCategory, SpendingTrend, Insight

router = APIRouter(prefix="/insights", tags=["insights"]) 

STORE = InsightsStore()


@router.get("/spending")
def spending():
    return {
        "categories": [c.dict() for c in STORE.categories],
        "trends": [t.dict() for t in STORE.trends],
        "tips": [i.dict() for i in STORE.tips],
    }

