from __future__ import annotations

from dataclasses import dataclass
from hashlib import sha256
from typing import Dict, Optional, List
from pydantic import BaseModel
from datetime import datetime
import random


class UserSecurity(BaseModel):
    user_id: str
    pin_hash: Optional[str] = None
    biometric_enabled: bool = False
    twofa_enabled: bool = False


class AuditLog(BaseModel):
    id: str
    user_id: str
    event: str
    timestamp: str


class _Otp(BaseModel):
    user_id: str
    code: str
    expires_at: str


def _now() -> str:
    return datetime.utcnow().isoformat()


def _hash(pin: str) -> str:
    return sha256(pin.encode()).hexdigest()


class SecurityStore:
    def __init__(self) -> None:
        self.users: Dict[str, UserSecurity] = {"u1": UserSecurity(user_id="u1")}
        self.audit: Dict[str, AuditLog] = {}
        self.otps: Dict[str, _Otp] = {}
        self._seq = 1

    def set_pin(self, user_id: str, pin: str) -> UserSecurity:
        if not pin.isdigit() or len(pin) not in (4, 6):
            raise ValueError("PIN must be 4 or 6 digits")
        u = self.users.setdefault(user_id, UserSecurity(user_id=user_id))
        u = u.copy(update={"pin_hash": _hash(pin)})
        self.users[user_id] = u
        self.log(user_id, "pin_set")
        return u

    def verify_pin(self, user_id: str, pin: str) -> bool:
        u = self.users.get(user_id)
        if not u or not u.pin_hash:
            return False
        ok = _hash(pin) == u.pin_hash
        self.log(user_id, "pin_verify_success" if ok else "pin_verify_fail")
        return ok

    def toggle_biometric(self, user_id: str, enabled: bool) -> UserSecurity:
        u = self.users.setdefault(user_id, UserSecurity(user_id=user_id))
        u = u.copy(update={"biometric_enabled": bool(enabled)})
        self.users[user_id] = u
        self.log(user_id, f"biometric_{'on' if enabled else 'off'}")
        return u

    def send_otp(self, user_id: str) -> _Otp:
        code = f"{random.randint(0, 999999):06d}"
        otp = _Otp(user_id=user_id, code=code, expires_at=_now())
        self.otps[user_id] = otp
        self.log(user_id, "otp_sent")
        return otp

    def verify_otp(self, user_id: str, code: str) -> bool:
        otp = self.otps.get(user_id)
        ok = bool(otp and otp.code == code)
        if ok:
            u = self.users.setdefault(user_id, UserSecurity(user_id=user_id))
            u = u.copy(update={"twofa_enabled": True})
            self.users[user_id] = u
            self.log(user_id, "otp_verified")
        else:
            self.log(user_id, "otp_invalid")
        return ok

    def privacy_export(self, user_id: str) -> Dict[str, str]:
        u = self.users.get(user_id) or UserSecurity(user_id=user_id)
        return {
            "user_id": user_id,
            "biometric_enabled": str(u.biometric_enabled),
            "twofa_enabled": str(u.twofa_enabled),
        }

    def privacy_delete(self, user_id: str) -> None:
        if user_id in self.users:
            self.users[user_id] = self.users[user_id].copy(update={"pin_hash": None, "biometric_enabled": False, "twofa_enabled": False})
        self.log(user_id, "privacy_delete")

    def log(self, user_id: str, event: str) -> AuditLog:
        lid = f"a{self._seq:06d}"; self._seq += 1
        log = AuditLog(id=lid, user_id=user_id, event=event, timestamp=_now())
        self.audit[lid] = log
        return log

