from fastapi import APIRouter
from datetime import date

router = APIRouter()

@router.get('/dashboard')
def get_dashboard():
    return {
        "wallet_balance": 1250.75,
        "linked_accounts": [
            {"bank": "Monzo", "balance": 800.50},
            {"bank": "HSBC", "balance": 450.25}
        ],
        "pintos_balance": 3400,
        "bills": [
            {"id": "b1", "name": "Thames Water", "logo_url": "https://via.placeholder.com/40", "due_date": str(date(2025, 9, 10)), "amount": 45.20, "status": "due"},
            {"id": "b2", "name": "Barclaycard", "logo_url": "https://via.placeholder.com/40", "due_date": str(date(2025, 9, 12)), "amount": 800.00, "status": "due"}
        ],
        "credit_score": {"value": 710, "band": "Good", "last_refreshed": str(date(2025, 9, 1))}
    }
