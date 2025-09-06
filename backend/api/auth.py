from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, EmailStr
from datetime import datetime, timedelta
import uuid
import hashlib
import logging

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/auth")

# In-memory storage
users = {}
sessions = {}


def _hash_password(password: str) -> str:
    return hashlib.sha256(password.encode()).hexdigest()


class SignupRequest(BaseModel):
    name: str
    email: EmailStr
    phone: str
    password: str


class SignupResponse(BaseModel):
    status: str
    user_id: str
    requires_kyc: bool = True


@router.post('/signup', response_model=SignupResponse)
def signup(payload: SignupRequest):
    if payload.email in users:
        raise HTTPException(status_code=400, detail="User exists")
    user_id = str(uuid.uuid4())
    users[payload.email] = {
        'id': user_id,
        'name': payload.name,
        'email': payload.email,
        'phone': payload.phone,
        'password_hash': _hash_password(payload.password),
        'kyc_status': 'pending',
    }
    logger.info("signup: %s", payload.email)
    return SignupResponse(status='ok', user_id=user_id)


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class LoginResponse(BaseModel):
    status: str
    session_token: str
    requires_2fa: bool = True


@router.post('/login', response_model=LoginResponse)
def login(payload: LoginRequest):
    user = users.get(payload.email)
    logger.info("login attempt: %s", payload.email)
    if not user or user['password_hash'] != _hash_password(payload.password):
        logger.warning("login failed: %s", payload.email)
        raise HTTPException(status_code=401, detail="invalid credentials")
    token = str(uuid.uuid4())
    sessions[token] = {
        'email': payload.email,
        'expires_at': datetime.utcnow() + timedelta(minutes=5),
    }
    return LoginResponse(status='ok', session_token=token)


class Verify2FARequest(BaseModel):
    session_token: str
    otp_code: str


@router.post('/verify-2fa')
def verify_2fa(payload: Verify2FARequest):
    session = sessions.get(payload.session_token)
    if not session or session['expires_at'] < datetime.utcnow():
        raise HTTPException(status_code=401, detail="session expired")
    if payload.otp_code != '123456':
        raise HTTPException(status_code=401, detail="invalid otp")
    return {'status': 'success'}


class ResetPasswordRequest(BaseModel):
    email: EmailStr


@router.post('/reset-password')
def reset_password(payload: ResetPasswordRequest):
    if payload.email not in users:
        logger.warning("reset-password unknown email: %s", payload.email)
    return {'status': 'sent'}
