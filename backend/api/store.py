from fastapi import APIRouter, HTTPException
from .models.store_item import InMemoryStore, StoreItem

router = APIRouter(prefix="/store", tags=["store"])

STORE = InMemoryStore()


@router.get("", response_model=list[StoreItem])
def list_store():
  return STORE.list()


@router.get("/{item_id}", response_model=StoreItem)
def get_item(item_id: str):
  item = STORE.get(item_id)
  if not item:
    raise HTTPException(status_code=404, detail="not found")
  return item

