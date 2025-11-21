# Memory RAG Backend

This is a FastAPI backend for a memory-based RAG application.

## Setup

1.  **Install Dependencies**:
    ```bash
    pip install -r requirements.txt
    ```

2.  **Environment Variables**:
    Copy `.env.example` to `.env` and add your OpenAI API Key.
    ```bash
    cp .env.example .env
    ```

3.  **Run the Server**:
    ```bash
    uvicorn main:app --reload
    ```
    The API will be available at `http://localhost:8000`.
    Swagger UI: `http://localhost:8000/docs`

## Endpoints

-   `POST /memory/record`: Record a new memory (text + tone).
-   `POST /memory/text`: Record a text memory.
-   `GET /timeline`: Get memories, optionally filtered by date (`?date=YYYY-MM-DD`).
-   `POST /ask`: Ask the AI about your memories.

## Project Structure

-   `/app/api`: API route handlers.
-   `/app/models`: Pydantic data models.
-   `/app/services`: Core business logic (Embedding, FAISS, Storage).
-   `/app/rag`: RAG specific logic.
-   `/app/utils`: Utility functions.
-   `/faiss_index`: Local storage for FAISS index.
-   `memories.json`: Local storage for metadata.

## How to Update FAISS
The FAISS index is automatically updated and saved to disk whenever a new memory is added via the `/memory/record` or `/memory/text` endpoints.

## How to Query FAISS
Use the `/ask` endpoint. It generates an embedding for your query, searches the FAISS index for relevant memories, and uses them as context for the LLM.
