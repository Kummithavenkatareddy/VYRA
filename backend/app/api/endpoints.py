from fastapi import APIRouter, HTTPException, Query
from app.models.schemas import MemoryCreate, MemoryResponse, TimelineResponse, QueryRequest, QueryResponse
from app.services.embedding import embedding_service
from app.services.faiss_store import faiss_store
from app.services.storage import storage_service
from app.rag.rag_engine import rag_engine
from app.utils.text_processing import chunk_text
import uuid
from datetime import datetime

router = APIRouter()

@router.post("/memory/record", response_model=MemoryResponse)
async def record_memory(memory: MemoryCreate):
    # 1. Generate ID and Timestamp
    mem_id = str(uuid.uuid4())
    now = datetime.now()
    date_str = now.strftime("%Y-%m-%d")
    time_str = now.strftime("%H:%M:%S")
    
    # 2. Chunk text
    chunks = chunk_text(memory.text)
    
    # 3. Generate Embeddings and Store in FAISS
    # We need to store each chunk or the whole text? 
    # Requirement says "Preprocess + chunk text". 
    # Usually we store chunks in FAISS but metadata links to the main memory.
    # For simplicity, let's store the whole text embedding for now as the primary retrieval unit, 
    # or if we chunk, we need to handle multiple vectors per memory.
    # Given the simple requirement "Store embeddings in FAISS with a unique memory ID",
    # let's assume one vector per memory for the main text, or average of chunks, or just first chunk.
    # BETTER APPROACH: Store each chunk as a separate vector, all pointing to the same memory ID in metadata?
    # FAISS FlatL2 uses int IDs. We need a global counter or manage our own ID mapping.
    # Let's use a simple global counter for FAISS IDs stored in storage or just len(storage).
    
    # To keep it simple and robust:
    # We will assign a unique integer ID for FAISS for this memory entry.
    # If we have multiple chunks, we would add multiple vectors.
    # But `storage_service` is list-based.
    # Let's simplify: 1 Memory Entry = 1 Vector (of the full text or first chunk).
    # If text is long, we might lose info.
    # Let's stick to: 1 Memory = 1 Vector (embedding of the full text) for this MVP unless specified otherwise.
    # The requirement says "Chunking strategy for long text".
    # So we SHOULD chunk.
    
    # Revised approach for Chunking:
    # 1 Memory Entry (Metadata) -> Multiple Chunks (Vectors).
    # But `get_memory_by_faiss_id` needs to map back to the Memory Entry.
    # So we need: FAISS ID -> Memory ID.
    # We can store this in the metadata: "faiss_ids": [1, 2, 3]
    # And we need a reverse lookup or just iterate.
    
    # Let's get current max ID from storage to know where to start?
    # FAISS IDs must be unique across ALL memories.
    # We can use a global counter file or just `faiss_store.index.ntotal`.
    
    start_faiss_id = faiss_store.index.ntotal
    
    embeddings = embedding_service.generate_embeddings(chunks)
    faiss_ids = [start_faiss_id + i for i in range(len(embeddings))]
    
    faiss_store.add_embeddings(embeddings, faiss_ids)
    
    # 4. Save Metadata
    # We need to store which FAISS IDs belong to this memory to allow reverse lookup if needed,
    # but more importantly, for RAG, we get a FAISS ID and need to find the Memory.
    # So we should store a mapping.
    # In `storage_service`, we can store a list of objects where each object is a memory.
    # We can add a field `faiss_ids` to the memory object.
    # And `get_memory_by_faiss_id` will search through all memories and check if the ID is in `faiss_ids`.
    
    memory_data = {
        "id": mem_id,
        "text": memory.text,
        "tone": memory.tone,
        "date": date_str,
        "time": time_str,
        "faiss_ids": faiss_ids
    }
    storage_service.add_memory(memory_data)
    
    return MemoryResponse(memory_id=mem_id, status="saved")

@router.post("/memory/text", response_model=MemoryResponse)
async def add_text_memory(memory: MemoryCreate):
    return await record_memory(memory)

@router.get("/timeline", response_model=list[TimelineResponse])
async def get_timeline(date: str = Query(None, description="Date in YYYY-MM-DD format")):
    if date:
        memories = storage_service.get_memories_by_date(date)
    else:
        memories = storage_service.get_all_memories()
    
    # Sort by date and time descending
    # Assuming date and time are strings in ISO format, they sort correctly.
    memories.sort(key=lambda x: (x['date'], x['time']), reverse=True)
    
    return [
        TimelineResponse(
            id=m['id'],
            text=m['text'],
            tone=m.get('tone', 'neutral'),
            date=m['date'],
            time=m['time']
        ) for m in memories
    ]

@router.post("/ask", response_model=QueryResponse)
async def ask_ai(query: QueryRequest):
    answer, used_memories = rag_engine.answer_query(query.query)
    return QueryResponse(answer=answer, used_memories=used_memories)
