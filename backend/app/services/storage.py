import json
import os
from typing import List, Dict, Optional
from datetime import datetime

class StorageService:
    def __init__(self):
        # Get the directory of the current file (app/services)
        current_dir = os.path.dirname(os.path.abspath(__file__))
        # Go up two levels to backend/
        backend_dir = os.path.dirname(os.path.dirname(current_dir))
        self.file_path = os.path.join(backend_dir, "memories.json")
        self._ensure_file()

    def _ensure_file(self):
        if not os.path.exists(self.file_path):
            with open(self.file_path, 'w') as f:
                json.dump([], f)

    def _load_data(self) -> List[Dict]:
        with open(self.file_path, 'r') as f:
            try:
                return json.load(f)
            except json.JSONDecodeError:
                return []

    def _save_data(self, data: List[Dict]):
        with open(self.file_path, 'w') as f:
            json.dump(data, f, indent=4)

    def add_memory(self, memory: Dict):
        data = self._load_data()
        data.append(memory)
        self._save_data(data)

    def get_all_memories(self) -> List[Dict]:
        return self._load_data()

    def get_memories_by_date(self, date_str: str) -> List[Dict]:
        data = self._load_data()
        return [m for m in data if m.get('date') == date_str]

    def get_memory_by_faiss_id(self, faiss_id: int) -> Optional[Dict]:
        data = self._load_data()
        # faiss_ids is a list in the memory object
        for m in data:
            if 'faiss_ids' in m and faiss_id in m['faiss_ids']:
                return m
        return None

# Singleton
storage_service = StorageService()
