from fastapi import APIRouter, HTTPException
from .models.security import SecurityStore, UserSecurity, AuditLog

router = APIRouter(prefix="/security", tags=["security"]) 
STORE = SecurityStore()


@router.post("/pin")
def set_pin(payload: dict) -> UserSecurity:
    pin = str(payload.get("pin", ""))
    try:
        return STORE.set_pin("u1", pin)
    except ValueError as e:
        raise HTTPException(status_code=422, detail=str(e))


@router.post("/pin/verify")
def verify_pin(payload: dict):
    pin = str(payload.get("pin", ""))
    ok = STORE.verify_pin("u1", pin)
    return {"ok": ok}


@router.post("/biometric/toggle")
def toggle_biometric(payload: dict) -> UserSecurity:
    enabled = bool(payload.get("enabled", False))
    return STORE.toggle_biometric("u1", enabled)


@router.post("/2fa/send")
def twofa_send():
    otp = STORE.send_otp("u1")
    # In real integration, send OTP via SMS/Email provider
    return {"status": "sent", "code": otp.code}  # exposing code for tests/demo


@router.post("/2fa/verify")
def twofa_verify(payload: dict):
    code = str(payload.get("code", ""))
    ok = STORE.verify_otp("u1", code)
    return {"ok": ok}


@router.get("/privacy/data")
def privacy_export():
    return STORE.privacy_export("u1")


@router.post("/privacy/delete")
def privacy_delete():
    STORE.privacy_delete("u1")
    return {"status": "deleted"}


@router.post("/audit")
def audit(payload: dict) -> AuditLog:
    event = str(payload.get("event", ""))
    return STORE.log("u1", event)

