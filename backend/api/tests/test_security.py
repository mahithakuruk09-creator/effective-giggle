from fastapi import FastAPI
from fastapi.testclient import TestClient
from backend.api.security import router


def app() -> FastAPI:
    a = FastAPI(); a.include_router(router); return a


def test_pin_and_biometric_and_2fa_and_privacy():
    a = app(); c = TestClient(a)

    # set/verify PIN
    r = c.post('/security/pin', json={'pin': '1234'})
    assert r.status_code == 200
    rv = c.post('/security/pin/verify', json={'pin': '1234'})
    assert rv.status_code == 200 and rv.json()['ok'] is True

    # biometric toggle
    b = c.post('/security/biometric/toggle', json={'enabled': True})
    assert b.status_code == 200 and b.json()['biometric_enabled'] is True

    # 2FA send/verify
    s = c.post('/security/2fa/send')
    assert s.status_code == 200
    code = s.json()['code']
    v = c.post('/security/2fa/verify', json={'code': code})
    assert v.status_code == 200 and v.json()['ok'] is True

    # privacy export/delete
    pe = c.get('/security/privacy/data')
    assert pe.status_code == 200 and 'user_id' in pe.json()
    pd = c.post('/security/privacy/delete')
    assert pd.status_code == 200 and pd.json()['status'] == 'deleted'

    # audit log
    al = c.post('/security/audit', json={'event': 'test_event'})
    assert al.status_code == 200 and al.json()['event'] == 'test_event'

