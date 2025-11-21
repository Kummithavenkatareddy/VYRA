from sentence_transformers import SentenceTransformer
import numpy as np

class EmbeddingService:
    def __init__(self, model_name: str = "sentence-transformers/all-MiniLM-L6-v2"):
        self.model = SentenceTransformer(model_name)

    def generate_embedding(self, text: str) -> np.ndarray:
        return self.model.encode([text])[0]

    def generate_embeddings(self, texts: list[str]) -> np.ndarray:
        return self.model.encode(texts)

# Singleton instance
embedding_service = EmbeddingService()
