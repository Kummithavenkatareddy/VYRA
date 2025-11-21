from fastapi import FastAPI, HTTPException, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
from backend.models.schemas import MemoryCreate, MemoryResponse, MemoryDetail, QueryRequest, QueryResponse
from backend.services.memory_service import memory_service
from backend.services.llm_service import llm_service
from backend.services.audio_service import audio_service
from backend.core.config import settings
from typing import List, Dict, Any

app = FastAPI(title=settings.PROJECT_NAME, version=settings.PROJECT_VERSION)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def root():
    return {"message": "AI Memory Prosthetic Backend is Running"}

@app.post("/api/v1/memories", response_model=MemoryResponse)
def add_memory(memory: MemoryCreate):
    try:
        # Construct metadata from schema fields
        metadata = memory.metadata or {}
        metadata["user_id"] = memory.user_id
        if memory.timestamp:
            metadata["timestamp"] = memory.timestamp
            
        memory_id = memory_service.add_memory(memory.text, metadata)
        return MemoryResponse(
            id=memory_id,
            status="success",
            message="Memory stored successfully"
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/v1/memories/audio", response_model=MemoryResponse)
def add_audio_memory(
    file: UploadFile = File(...),
    user_id: str = Form(...)
):
    try:
        # 1. Save file
        file_path = audio_service.save_file(file)
        
        # 2. Transcribe
        text = audio_service.transcribe(file_path)
        
        # 3. Store in Vector DB
        metadata = {"user_id": user_id, "source": "audio", "file_path": file_path}
        memory_id = memory_service.add_memory(text, metadata)
        
        return MemoryResponse(
            id=memory_id,
            status="success",
            message="Audio memory processed and stored"
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

from typing import Optional

@app.get("/api/v1/memories")
def get_memories(limit: int = 10, user_id: Optional[str] = None):
    try:
        return memory_service.get_all_memories(limit=limit, user_id=user_id)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/v1/memories/{memory_id}", response_model=MemoryDetail)
def get_memory_detail(memory_id: str):
    try:
        memory = memory_service.get_memory_by_id(memory_id)
        if not memory:
            raise HTTPException(status_code=404, detail="Memory not found")
        
        # Map metadata to top-level fields if they exist
        metadata = memory.get("metadata", {})
        return MemoryDetail(
            id=memory["id"],
            text=memory["text"],
            timestamp=metadata.get("timestamp"),
            tags=metadata.get("tags", []),
            emotion=metadata.get("emotion", "Neutral"),
            metadata=metadata
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/v1/query", response_model=QueryResponse)
def recall_memory(query: QueryRequest):
    try:
        # 1. Retrieve relevant memories for this user
        context = memory_service.query_memories(
            query_text=query.question,
            user_id=query.user_id,
            n_results=query.limit
        )
        
        # 2. Generate answer using LLM
        answer = llm_service.generate_response(query.question, context)
        
        return QueryResponse(
            answer=answer,
            sources=context
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
