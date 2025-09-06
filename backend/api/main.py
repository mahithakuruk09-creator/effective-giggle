from fastapi import FastAPI
from .auth import router as auth_router
from .dashboard import router as dashboard_router
from .payments import router as payments_router

app = FastAPI()

@app.get('/health')
def health():
    return {'status': 'ok'}

app.include_router(auth_router)
app.include_router(dashboard_router)
app.include_router(payments_router)
