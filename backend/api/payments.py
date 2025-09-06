from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter()

class PayBillRequest(BaseModel):
  biller_id: str
  amount: float
  source_account: str

class PayBillResponse(BaseModel):
  status: str
  pintos_earned: int

@router.post('/pay-bill', response_model=PayBillResponse)
async def pay_bill(req: PayBillRequest) -> PayBillResponse:
  rate = 0.5 if req.biller_id.startswith('cc') else 0.25
  pintos = int(req.amount * rate)
  return PayBillResponse(status='success', pintos_earned=pintos)
