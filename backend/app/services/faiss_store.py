import faiss
import numpy as np
import os
import pickle

class FAISSStore:
    def __init__(self, dimension: int = 384):
        # Get the directory of the current file (app/services)
        current_dir = os.path.dirname(os.path.abspath(__file__))
        # Go up two levels to backend/
        backend_dir = os.path.dirname(os.path.dirname(current_dir))
        self.index_path = os.path.join(backend_dir, "faiss_index", "index.faiss")
        self.dimension = dimension
        self.index = self._load_index()

    def _load_index(self):
        if os.path.exists(self.index_path):
            return faiss.read_index(self.index_path)
        else:
            return faiss.IndexFlatL2(self.dimension)

    def save_index(self):
        # Ensure directory exists
        os.makedirs(os.path.dirname(self.index_path), exist_ok=True)
        faiss.write_index(self.index, self.index_path)

    def add_embeddings(self, embeddings: np.ndarray, ids: list[int]):
        """
        Add embeddings to the index.
        Note: FAISS IndexFlatL2 uses integer IDs. We need to map UUIDs to integers if we want to retrieve by ID,
        or just use the index position. For simplicity, we'll assume the metadata store keeps track of the mapping
        between FAISS ID (int) and Memory ID (UUID).
        """
        if embeddings.shape[1] != self.dimension:
            raise ValueError(f"Embedding dimension mismatch. Expected {self.dimension}, got {embeddings.shape[1]}")
        
        # FAISS IndexFlatL2 doesn't support add_with_ids directly in the basic version without IDMap,
        # but for simplicity we can use IndexIDMap if we want explicit IDs.
        # Let's upgrade to IndexIDMap to support custom IDs.
        
        if not isinstance(self.index, faiss.IndexIDMap):
             # If it's a fresh index or just loaded as FlatL2, wrap it. 
             # However, read_index might return the wrapped one.
             # If we created a new FlatL2, we should wrap it.
             if isinstance(self.index, faiss.IndexFlatL2):
                 self.index = faiss.IndexIDMap(self.index)

        self.index.add_with_ids(embeddings, np.array(ids, dtype=np.int64))
        self.save_index()

    def search(self, query_embedding: np.ndarray, k: int = 5):
        distances, indices = self.index.search(query_embedding.reshape(1, -1), k)
        return distances[0], indices[0]

# Singleton
faiss_store = FAISSStore()
