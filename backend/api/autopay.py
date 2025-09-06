from fastapi import APIRouter, HTTPException
from .models.autopay import AutopayCreate, AutopayUpdate, InMemoryAutopayStore, Autopay

router = APIRouter(prefix="/autopay", tags=["autopay"])

store = InMemoryAutopayStore()


@router.get("", response_model=list[Autopay])
def list_autopay() -> list[Autopay]:
    return store.list()


@router.post("/add")
def add_autopay(payload: AutopayCreate):
    ap = store.add(payload)
    return {"status": "success", "autopay_id": ap.autopay_id}


@router.patch("/{autopay_id}")
def update_autopay(autopay_id: str, payload: AutopayUpdate):
    ap = store.update(autopay_id, payload)
    if not ap:
        raise HTTPException(status_code=404, detail="Not found")
    return {"status": "updated"}


@router.post("/{autopay_id}/toggle")
def toggle_autopay(autopay_id: str, payload: dict):
    enabled = payload.get("enabled")
    if not isinstance(enabled, bool):
        raise HTTPException(status_code=400, detail="enabled must be boolean")
    ap = store.update(autopay_id, AutopayUpdate(enabled=enabled))
    if not ap:
        raise HTTPException(status_code=404, detail="Not found")
    return {"autopay_id": autopay_id, "enabled": enabled}


@router.delete("/{autopay_id}")
def delete_autopay(autopay_id: str):
    ok = store.delete(autopay_id)
    if not ok:
        raise HTTPException(status_code=404, detail="Not found")
    return {"status": "deleted"}

