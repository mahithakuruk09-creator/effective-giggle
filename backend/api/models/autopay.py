from __future__ import annotations

from pydantic import BaseModel, Field, validator
from typing import Literal, Optional, Dict, List

AutopayType = Literal["minimum", "full", "fixed"]


class AutopayCreate(BaseModel):
    biller_id: str
    type: AutopayType
    cap: Optional[float] = None
    pre_alert_days: int = Field(ge=0, le=7, default=0)
    enabled: bool = True


class AutopayUpdate(BaseModel):
    type: Optional[AutopayType] = None
    cap: Optional[float] = None
    pre_alert_days: Optional[int] = Field(default=None, ge=0, le=7)
    enabled: Optional[bool] = None


class Autopay(BaseModel):
    autopay_id: str
    biller_id: str
    type: AutopayType
    cap: Optional[float]
    pre_alert_days: int
    enabled: bool


class InMemoryAutopayStore:
    def __init__(self) -> None:
        self._items: Dict[str, Autopay] = {}
        self._seq = 1

    def _next_id(self) -> str:
        i = self._seq
        self._seq += 1
        return f"ap_{i:03d}"

    def add(self, data: AutopayCreate) -> Autopay:
        ap_id = self._next_id()
        ap = Autopay(
            autopay_id=ap_id,
            biller_id=data.biller_id,
            type=data.type,
            cap=data.cap,
            pre_alert_days=data.pre_alert_days,
            enabled=data.enabled,
        )
        self._items[ap_id] = ap
        return ap

    def list(self) -> List[Autopay]:
        return list(self._items.values())

    def get(self, autopay_id: str) -> Optional[Autopay]:
        return self._items.get(autopay_id)

    def update(self, autopay_id: str, data: AutopayUpdate) -> Optional[Autopay]:
        ap = self._items.get(autopay_id)
        if not ap:
            return None
        updated = ap.copy(update={
            **({"type": data.type} if data.type is not None else {}),
            **({"cap": data.cap} if data.cap is not None else {}),
            **({"pre_alert_days": data.pre_alert_days} if data.pre_alert_days is not None else {}),
            **({"enabled": data.enabled} if data.enabled is not None else {}),
        })
        self._items[autopay_id] = updated
        return updated

    def delete(self, autopay_id: str) -> bool:
        return self._items.pop(autopay_id, None) is not None

