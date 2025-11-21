import os
from dotenv import load_dotenv

load_dotenv()

class Settings:
    PROJECT_NAME: str = "AI Memory Prosthetic"
    PROJECT_VERSION: str = "1.0.0"
    
    # API Keys
    GOOGLE_API_KEY: str = os.getenv("GOOGLE_API_KEY", "")
    OPENAI_API_KEY: str = os.getenv("OPENAI_API_KEY", "")
    
    # Database
    # Use absolute path relative to this file's parent (backend/core/..) -> backend/chroma_db
    BASE_DIR: str = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    CHROMA_DB_DIR: str = os.path.join(BASE_DIR, "chroma_db")

settings = Settings()
