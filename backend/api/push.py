from fastapi import APIRouter, HTTPException
from typing import Dict, Set


class PushStore:
    def __init__(self) -> None:
        self.tokens: Set[str] = set()
        self.topics: Dict[str, Set[str]] = {}

    def register(self, token: str) -> None:
        if not token:
            raise ValueError("token required")
        self.tokens.add(token)
        self.topics.setdefault(token, set())

    def subscribe(self, token: str, topic: str) -> None:
        if token not in self.tokens:
            raise KeyError("unknown token")
        self.topics.setdefault(token, set()).add(topic)

    def unsubscribe(self, token: str, topic: str) -> None:
        if token not in self.tokens:
            raise KeyError("unknown token")
        self.topics.setdefault(token, set()).discard(topic)

    def list_topics(self, token: str) -> Set[str]:
        return self.topics.get(token, set())


STORE = PushStore()
router = APIRouter(prefix="/push", tags=["push"])


@router.post("/token")
def register_token(payload: dict):
    token = payload.get("token")
    try:
        STORE.register(token)
        return {"status": "registered"}
    except ValueError as e:
        raise HTTPException(status_code=422, detail=str(e))


@router.post("/subscribe")
def subscribe(payload: dict):
    token = payload.get("token")
    topic = payload.get("topic")
    try:
        STORE.subscribe(token, topic)
        return {"status": "subscribed"}
    except KeyError:
        raise HTTPException(status_code=404, detail="unknown token")


@router.post("/unsubscribe")
def unsubscribe(payload: dict):
    token = payload.get("token")
    topic = payload.get("topic")
    try:
        STORE.unsubscribe(token, topic)
        return {"status": "unsubscribed"}
    except KeyError:
        raise HTTPException(status_code=404, detail="unknown token")


@router.get("/topics")
def topics(token: str):
    return {"topics": sorted(list(STORE.list_topics(token)))}

