from __future__ import annotations

from pydantic import BaseModel
from typing import List, Dict, Optional
from datetime import datetime


class SpendingCategory(BaseModel):
    category: str
    amount: int
    percentage: float


class SpendingTrend(BaseModel):
    month: str  # YYYY-MM
    total: int


class Insight(BaseModel):
    id: str
    text: str
    category: Optional[str] = None
    created_at: str


class NotificationItem(BaseModel):
    id: str
    type: str  # bill_due, rewards, repayment, security
    title: str
    body: str
    cta: Optional[str] = None
    status: str  # unread, done, dismissed


class InsightsStore:
    def __init__(self) -> None:
        self.categories: List[SpendingCategory] = [
            SpendingCategory(category="Dining", amount=220, percentage=0.22),
            SpendingCategory(category="Shopping", amount=310, percentage=0.31),
            SpendingCategory(category="Travel", amount=120, percentage=0.12),
            SpendingCategory(category="Utilities", amount=180, percentage=0.18),
            SpendingCategory(category="Others", amount=170, percentage=0.17),
        ]
        self.trends: List[SpendingTrend] = [
            SpendingTrend(month="2025-07", total=850),
            SpendingTrend(month="2025-08", total=930),
            SpendingTrend(month="2025-09", total=1000),
        ]
        self.tips: List[Insight] = [
            Insight(id="i1", text="Dining spend up 20% this month.", category="Dining", created_at=_now()),
            Insight(id="i2", text="Consider switching your broadband – you overspent £25 vs average user.", category="Utilities", created_at=_now()),
        ]
        self.notifications: Dict[str, NotificationItem] = {
            "n1": NotificationItem(id="n1", type="bill_due", title="Council Tax due in 3 days", body="Tap to pay now.", cta="Pay Now", status="unread"),
            "n2": NotificationItem(id="n2", type="rewards", title="Pintos earned", body="You earned 120 Pintos.", cta="Redeem", status="unread"),
            "n3": NotificationItem(id="n3", type="repayment", title="Loan repayment tomorrow", body="£185 due.", cta="View Loan", status="unread"),
            "n4": NotificationItem(id="n4", type="security", title="New login detected", body="London • iPhone", cta=None, status="unread"),
        }

    def action(self, notif_id: str) -> NotificationItem:
        n = self.notifications.get(notif_id)
        if not n:
            raise KeyError("not found")
        self.notifications[notif_id] = n.copy(update={"status": "done"})
        return self.notifications[notif_id]


def _now() -> str:
    return datetime.utcnow().isoformat()

