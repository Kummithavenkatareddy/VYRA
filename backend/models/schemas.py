from pydantic import BaseModel
from typing import List, Optional, Dict, Any

class MemoryCreate(BaseModel):
    user_id: str
    text: str
    timestamp: Optional[str] = None # ISO8601 string
    metadata: Optional[Dict[str, Any]] = {}

class MemoryResponse(BaseModel):
    id: str
    status: str
    message: str

class MemoryDetail(BaseModel):
    id: str
    text: str
    timestamp: Optional[str] = None
    tags: List[str] = []
    emotion: Optional[str] = "Neutral" # Placeholder
    metadata: Dict[str, Any] = {}

class QueryRequest(BaseModel):
    user_id: str
    question: str
    limit: int = 5

class QueryResponse(BaseModel):
    answer: str
    sources: List[Dict[str, Any]]
