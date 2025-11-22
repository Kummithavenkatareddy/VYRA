from app.services.embedding import embedding_service
from app.services.faiss_store import faiss_store
from app.services.storage import storage_service
from app.models.schemas import TimelineResponse
import google.generativeai as genai
import numpy as np
import os


class RAGEngine:
    def __init__(self):
        """Initialize Gemini API and model."""
        self.api_key = os.getenv("GOOGLE_API_KEY")

        if self.api_key:
            genai.configure(api_key=self.api_key)
            # Gemini 1.5 Flash = fast + cheap + perfect for RAG
            self.model = genai.GenerativeModel("gemini-2.5-pro")
        else:
            self.model = None

    def _get_llm_response(self, context: str, query: str) -> str:
        """Generate a response using Gemini with memory-aware instructions."""
        if not self.model:
            return "Google API Key is missing. Please set GOOGLE_API_KEY in your .env file."

        try:
            system_instruction = (
                "You are a helpful personal AI assistant.\n"
                "You have access to the user's past memories in the 'Context'.\n\n"
                "RULES:\n"
                "1. MEMORY QUESTIONS:\n"
                "   If the user asks about their past (e.g., 'What did I do?', "
                "'Who did I meet?'), answer ONLY using the Context.\n"
                "   If the answer is not present, politely say you don't remember.\n\n"
                "2. GENERAL QUESTIONS:\n"
                "   If the user asks for advice, learning paths, or career guidance, "
                "use your general knowledge.\n"
                "   PERSONALIZE the answer using clues from the Context when possible."
            )

            full_prompt = (
                f"{system_instruction}\n\n"
                f"Context Memories:\n{context}\n\n"
                f"User Question: {query}"
            )

            response = self.model.generate_content(full_prompt)
            return response.text.strip()

        except Exception as e:
            return f"Error generating answer with Gemini: {str(e)}"

    def answer_query(self, query: str):
        """Full RAG workflow: embed → search → retrieve memories → call Gemini."""
        # 1. Embed query
        query_embedding = embedding_service.generate_embedding(query)

        # 2. Search FAISS index
        distances, indices = faiss_store.search(query_embedding, k=5)

        # --- NUMPY compatibility fix ---
        if hasattr(indices, "flatten"):
            search_indices = indices.flatten()
        elif isinstance(indices, list) and len(indices) > 0 and isinstance(indices[0], list):
            search_indices = indices[0]
        else:
            search_indices = indices

        # 3. Retrieve stored memory metadata
        memories = [
            storage_service.get_memory_by_faiss_id(int(idx))
            for idx in search_indices
            if int(idx) != -1
        ]

        valid_memories = [m for m in memories if m]

        # 4. Build memory context
        context_parts = [
            f"- [{m['date']}]: {m['text']} (Tone: {m.get('tone', 'neutral')})"
            for m in valid_memories
        ]

        context_text = (
            "\n".join(context_parts)
            if context_parts
            else "No relevant past memories found."
        )

        # 5. Convert to TimelineResponse objects
        relevant_memories = [
            TimelineResponse(
                id=m["id"],
                text=m["text"],
                tone=m.get("tone", "neutral"),
                date=m["date"],
                time=m["time"],
            )
            for m in valid_memories
        ]

        # 6. Get LLM answer
        answer = self._get_llm_response(context_text, query)

        return answer, relevant_memories


# Singleton instance
rag_engine = RAGEngine()
