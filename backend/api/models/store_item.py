from __future__ import annotations

from pydantic import BaseModel
from typing import List, Dict, Optional


class StoreItem(BaseModel):
  id: str
  title: str
  description: str
  category: str
  price: int
  image_url: str


class InMemoryStore:
  def __init__(self) -> None:
    self._items: Dict[str, StoreItem] = {i.id: i for i in DEFAULT_ITEMS}

  def list(self) -> List[StoreItem]:
    return list(self._items.values())

  def get(self, item_id: str) -> Optional[StoreItem]:
    return self._items.get(item_id)


DEFAULT_ITEMS: List[StoreItem] = [
  StoreItem(id='s1', title='Tesco £5 Voucher', description='Redeem in Tesco stores across UK', category='Retail', price=500, image_url='dummy_tesco.png'),
  StoreItem(id='s2', title='Greggs Coffee', description='Freshly brewed Greggs coffee', category='Food', price=200, image_url='dummy_greggs.png'),
  StoreItem(id='s3', title='Amazon £10 UK', description='Spend on Amazon UK', category='Retail', price=800, image_url='dummy_amazon.png'),
  StoreItem(id='s4', title='Deliveroo £7', description='Order from your favourites', category='Food', price=600, image_url='dummy_deliveroo.png'),
  StoreItem(id='s5', title='Pret Coffee', description='Pret a Manger hot drink', category='Food', price=300, image_url='dummy_pret.png'),
  StoreItem(id='s6', title='Trainline £15', description='National rail travel credit', category='Travel', price=1200, image_url='dummy_trainline.png'),
]

