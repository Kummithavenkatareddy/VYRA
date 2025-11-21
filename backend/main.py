from fastapi import FastAPI
from dotenv import load_dotenv
import os

# Load environment variables first
load_dotenv()

from app.api.endpoints import router

app = FastAPI(title="Memory RAG Backend", version="1.0.0")

app.include_router(router)

@app.get("/")
async def root():
    return {"message": "Memory RAG Backend is running"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
