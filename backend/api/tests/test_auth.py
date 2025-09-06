from fastapi.testclient import TestClient
from backend.api.main import app

client = TestClient(app)


def test_signup_and_login_flow():
    resp = client.post('/auth/signup', json={
        'name': 'Tester',
        'email': 't@example.com',
        'phone': '1234567890',
        'password': 'password1'
    })
    assert resp.status_code == 200
    token_resp = client.post('/auth/login', json={'email': 't@example.com', 'password': 'password1'})
    assert token_resp.status_code == 200
    token = token_resp.json()['session_token']
    otp_fail = client.post('/auth/verify-2fa', json={'session_token': token, 'otp_code': '000000'})
    assert otp_fail.status_code == 401
    otp_ok = client.post('/auth/verify-2fa', json={'session_token': token, 'otp_code': '123456'})
    assert otp_ok.status_code == 200


def test_reset_password():
    resp = client.post('/auth/reset-password', json={'email': 'no@user.com'})
    assert resp.status_code == 200
    assert resp.json()['status'] == 'sent'
