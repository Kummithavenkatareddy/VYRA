import chromadb
from chromadb.config import Settings as ChromaSettings
from backend.core.config import settings
import uuid
from typing import List, Dict, Any

class MemoryService:
    def __init__(self):
        self.client = chromadb.PersistentClient(path=settings.CHROMA_DB_DIR)
        self.collection = self.client.get_or_create_collection(name="memories")

    def add_memory(self, text: str, metadata: Dict[str, Any] = None) -> str:
        memory_id = str(uuid.uuid4())
        if metadata is None:
            metadata = {}
        
        # Add timestamp if not present
        # In a real app, we'd use a proper embedding function here.
        # ChromaDB uses a default one (Sentence Transformers) if none provided.
        
        self.collection.add(
            documents=[text],
            metadatas=[metadata],
            ids=[memory_id]
        )
        return memory_id

    def query_memories(self, query_text: str, user_id: str = None, n_results: int = 5) -> List[Dict[str, Any]]:
        where_clause = {"user_id": user_id} if user_id else None
        
        results = self.collection.query(
            query_texts=[query_text],
            n_results=n_results,
            where=where_clause
        )
        
        # Format results
        formatted_results = []
        if results['documents']:
            for i in range(len(results['documents'][0])):
                formatted_results.append({
                    "id": results['ids'][0][i],
                    "text": results['documents'][0][i],
                    "metadata": results['metadatas'][0][i] if results['metadatas'] else {}
                })
        return formatted_results

    def get_all_memories(self, limit: int = 10, user_id: str = None) -> List[Dict[str, Any]]:
        if user_id:
            # Filter by user_id if provided
            results = self.collection.get(
                where={"user_id": user_id},
                limit=limit
            )
        else:
            # Peek returns the first N items if no filter
            results = self.collection.peek(limit=limit)
            
        formatted_results = []
        if results['ids']:
            for i in range(len(results['ids'])):
                formatted_results.append({
                    "id": results['ids'][i],
                    "text": results['documents'][i],
                    "metadata": results['metadatas'][i] if results['metadatas'] else {}
                })
        
        # Sort by timestamp descending
        # Assuming timestamp is in metadata as ISO8601 string
        formatted_results.sort(
            key=lambda x: x['metadata'].get('timestamp', ''),
            reverse=True
        )
        
        return formatted_results

    def get_memory_by_id(self, memory_id: str) -> Dict[str, Any]:
        results = self.collection.get(ids=[memory_id])
        if results['ids']:
            return {
                "id": results['ids'][0],
                "text": results['documents'][0],
                "metadata": results['metadatas'][0] if results['metadatas'] else {}
            }
        return None

memory_service = MemoryService()
