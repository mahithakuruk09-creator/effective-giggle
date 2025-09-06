from __future__ import annotations

from pydantic import BaseModel, Field
from typing import List, Dict, Optional
from datetime import datetime


class Variant(BaseModel):
    id: str
    product_id: str
    option: str  # e.g., "S", "M", "L", "Black"
    stock: int


class Review(BaseModel):
    id: str
    product_id: str
    rating: int = Field(ge=1, le=5)
    comment: str


class Product(BaseModel):
    id: str
    name: str
    category: str  # Apparel, Gadgets, Lifestyle, Digital
    price: int  # in GBP (integer for simplicity)
    stock: int
    images: List[str]
    variants: List[Variant] = []
    description: str = ""


class CartItem(BaseModel):
    id: str
    user_id: str
    product_id: str
    qty: int = Field(gt=0)


class Order(BaseModel):
    id: str
    user_id: str
    items: List[CartItem]
    total: int
    status: str
    created_at: str


class RewardAccount(BaseModel):
    user_id: str
    balance: int = 0


class InMemoryShop:
    def __init__(self) -> None:
        self.products: Dict[str, Product] = {}
        self.variants: Dict[str, Variant] = {}
        self.reviews: Dict[str, Review] = {}
        self.carts: Dict[str, Dict[str, CartItem]] = {}  # user_id -> {cart_item_id: CartItem}
        self.orders: Dict[str, Order] = {}
        self.wishlists: Dict[str, List[str]] = {}  # user_id -> product_ids
        self.rewards: Dict[str, RewardAccount] = {}
        self._seq = 1
        self.seed()

    def _id(self, prefix: str) -> str:
        i = self._seq
        self._seq += 1
        return f"{prefix}_{i:04d}"

    def seed(self) -> None:
        # Seed 8 products across 4 categories
        def add(name: str, category: str, price: int, stock: int, images: List[str], description: str = ""):
            pid = self._id('p')
            prod = Product(id=pid, name=name, category=category, price=price, stock=stock, images=images, description=description)
            self.products[pid] = prod
            # simple size variants for apparel
            if category == 'Apparel':
                for opt in ['S', 'M', 'L', 'XL']:
                    vid = self._id('v')
                    var = Variant(id=vid, product_id=pid, option=opt, stock=stock // 4)
                    self.variants[vid] = var
            return pid

        add('Monochrome Hoodie', 'Apparel', 59, 50, ['hoodie1', 'hoodie2'])
        add('Minimalist Tee', 'Apparel', 25, 120, ['tee1'])
        add('Wireless Earbuds', 'Gadgets', 79, 35, ['buds1'])
        add('Smartwatch Lite', 'Gadgets', 129, 20, ['watch1'])
        add('Aromatherapy Candle', 'Lifestyle', 18, 200, ['candle1'])
        add('Office Desk Plant', 'Lifestyle', 22, 150, ['plant1'])
        add('Cloud Storage 1TB', 'Digital', 99, 1000, ['cloud1'])
        add('E‑book Bundle', 'Digital', 15, 10000, ['ebook1'])

    # Product ops
    def list_products(self, category: Optional[str], search: Optional[str]) -> List[Product]:
        items = list(self.products.values())
        if category:
            items = [p for p in items if p.category.lower() == category.lower()]
        if search:
            s = search.lower()
            items = [p for p in items if s in p.name.lower()]
        return items

    def get_product(self, pid: str) -> Optional[Product]:
        p = self.products.get(pid)
        if p:
            # attach variants for ease
            vs = [v for v in self.variants.values() if v.product_id == pid]
            return p.copy(update={'variants': vs})
        return None

    # Cart ops
    def add_to_cart(self, user_id: str, product_id: str, qty: int) -> CartItem:
        if product_id not in self.products:
            raise KeyError('product not found')
        if qty <= 0:
            raise ValueError('qty must be > 0')
        cart = self.carts.setdefault(user_id, {})
        # if exists, increment
        for it in cart.values():
            if it.product_id == product_id:
                it.qty += qty
                return it
        cid = self._id('ci')
        item = CartItem(id=cid, user_id=user_id, product_id=product_id, qty=qty)
        cart[cid] = item
        return item

    def list_cart(self, user_id: str) -> List[CartItem]:
        return list(self.carts.get(user_id, {}).values())

    def update_cart(self, user_id: str, cart_item_id: str, qty: int) -> CartItem:
        cart = self.carts.setdefault(user_id, {})
        if cart_item_id not in cart:
            raise KeyError('cart item not found')
        if qty <= 0:
            del cart[cart_item_id]
            raise ValueError('deleted')
        cart[cart_item_id].qty = qty
        return cart[cart_item_id]

    def delete_cart_item(self, user_id: str, cart_item_id: str) -> None:
        cart = self.carts.setdefault(user_id, {})
        cart.pop(cart_item_id, None)

    # Rewards
    def rewards_for(self, user_id: str) -> RewardAccount:
        acc = self.rewards.setdefault(user_id, RewardAccount(user_id=user_id, balance=0))
        return acc

    # Checkout
    def checkout(self, user_id: str, redeem: int) -> Order:
        cart = self.carts.get(user_id, {})
        items = list(cart.values())
        total = sum(self.products[i.product_id].price * i.qty for i in items)
        if any(self.products[i.product_id].stock < i.qty for i in items):
            raise ValueError('insufficient stock')
        # apply redeem
        acc = self.rewards_for(user_id)
        use = min(redeem, acc.balance, total)
        acc.balance -= use
        payable = total - use
        # earn 1 Pinto per £1 spent
        acc.balance += payable
        # reduce stock
        for i in items:
            p = self.products[i.product_id]
            self.products[i.product_id] = p.copy(update={'stock': p.stock - i.qty})
        # create order
        oid = self._id('ord')
        order = Order(id=oid, user_id=user_id, items=items, total=total, status='confirmed', created_at=datetime.utcnow().isoformat())
        self.orders[oid] = order
        # clear cart
        self.carts[user_id] = {}
        return order

