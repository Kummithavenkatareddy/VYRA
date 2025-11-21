from pydantic import BaseModel
from typing import List, Optional
from datetime import date, time

class MemoryCreate(BaseModel):
    text: str
    tone: Optional[str] = "neutral"

class MemoryResponse(BaseModel):
    memory_id: str
    status: str
    message: Optional[str] = None

class TimelineResponse(BaseModel):
    id: str
    text: str
    tone: str
    date: str
    time: str

class QueryRequest(BaseModel):
    query: str

class QueryResponse(BaseModel):
    answer: str
    used_memories: List[TimelineResponse]
