from app.services.embedding import embedding_service
from app.services.faiss_store import faiss_store
from app.services.storage import storage_service
from app.models.schemas import TimelineResponse
import os
# import openai # Uncomment when key is available

class RAGEngine:
    def __init__(self):
        self.api_key = os.getenv("OPENAI_API_KEY")

    def _get_llm_response(self, context: str, query: str) -> str:
        """
        Placeholder for LLM call.
        """
        if not self.api_key:
            return "OpenAI API Key not found. Please set OPENAI_API_KEY in .env file. Context retrieved: " + context[:100] + "..."
        
        # Placeholder implementation
        # client = openai.OpenAI(api_key=self.api_key)
        # response = client.chat.completions.create(
        #     model="gpt-3.5-turbo",
        #     messages=[
        #         {"role": "system", "content": "You are a helpful assistant with access to the user's past memories."},
        #         {"role": "user", "content": f"Context:\n{context}\n\nQuestion: {query}"}
        #     ]
        # )
        # return response.choices[0].message.content
        
        return f"[MOCK LLM RESPONSE] Based on your memories: {context[:200]}... I can answer: {query}"

    def answer_query(self, query: str):
        # 1. Generate embedding for query
        query_embedding = embedding_service.generate_embedding(query)
        
        # 2. Search FAISS
        distances, indices = faiss_store.search(query_embedding, k=3)
        
        # 3. Retrieve metadata
        relevant_memories = []
        context_parts = []
        
        for idx in indices:
            if idx == -1: continue
            memory = storage_service.get_memory_by_faiss_id(int(idx))
            if memory:
                # Convert to TimelineResponse for consistency in return
                mem_obj = TimelineResponse(
                    id=memory['id'],
                    text=memory['text'],
                    tone=memory.get('tone', 'neutral'),
                    date=memory['date'],
                    time=memory['time']
                )
                relevant_memories.append(mem_obj)
                context_parts.append(f"[{memory['date']}]: {memory['text']}")
        
        context = "\n".join(context_parts)
        
        # 4. Call LLM
        answer = self._get_llm_response(context, query)
        
        return answer, relevant_memories

rag_engine = RAGEngine()
