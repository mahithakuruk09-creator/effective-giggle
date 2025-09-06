from fastapi import APIRouter, HTTPException
from .models.insights import InsightsStore, NotificationItem

router = APIRouter(prefix="/notifications", tags=["notifications"]) 

STORE = InsightsStore()  # separate instance is fine for mocks


@router.get("")
def list_notifications() -> list[NotificationItem]:
    return list(STORE.notifications.values())


@router.post("/{notif_id}/action")
def act(notif_id: str):
    try:
        n = STORE.action(notif_id)
        return {"status": "ok", "notification": n}
    except KeyError:
        raise HTTPException(status_code=404, detail="not found")

