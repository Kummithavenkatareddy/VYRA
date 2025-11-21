import shutil
import os
import uuid
from fastapi import UploadFile
from backend.core.config import settings

class AudioService:
    def __init__(self):
        self.upload_dir = os.path.join(settings.BASE_DIR, "uploads")
        os.makedirs(self.upload_dir, exist_ok=True)

    def save_file(self, file: UploadFile) -> str:
        file_path = os.path.join(self.upload_dir, f"{uuid.uuid4()}_{file.filename}")
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        return file_path

    def transcribe(self, file_path: str) -> str:
        # TODO: Integrate with Whisper or Gemini Audio
        # For now, return a placeholder to unblock the frontend
        return f"Transcribed text from {os.path.basename(file_path)}"

audio_service = AudioService()
