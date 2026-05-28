# VYRA

VYRA is a personal memory assistant that captures text and voice memories, stores them as embeddings, and uses a retrieval-augmented generation (RAG) workflow to answer queries about your past.

## What VYRA Does

- Capture personal memories as text entries.
- Store memory metadata in `memories.json`.
- Generate embeddings with `sentence-transformers/all-MiniLM-L6-v2`.
- Persist a FAISS vector index in `backend/faiss_index/index.faiss`.
- Search relevant memories with FAISS and assemble them as context for an LLM.
- Answer user questions with Google Gemini (`google.generativeai`).
- Provide a Flutter frontend for memory capture, timeline browsing, and AI chat.

## Architecture

### Backend

- `backend/main.py` — FastAPI application entrypoint.
- `backend/app/api/endpoints.py` — REST API routes:
  - `POST /memory/record` — record a new memory.
  - `POST /memory/text` — alias for recording a text memory.
  - `GET /timeline` — fetch stored memories, optionally filtered by date.
  - `POST /ask` — query Vyra with a natural language question.
- `backend/app/services/embedding.py` — generates embeddings using SentenceTransformers.
- `backend/app/services/faiss_store.py` — manages the FAISS index and ID mapping.
- `backend/app/services/storage.py` — stores metadata in `memories.json`.
- `backend/app/rag/rag_engine.py` — executes the RAG flow and calls Gemini.
- `backend/app/utils/text_processing.py` — chunks long memory text into overlapping chunks.

### Frontend

- `frontend/lib/main.dart` — Flutter app entry and route setup.
- `frontend/lib/services/api_service.dart` — HTTP client for backend endpoints.
- `frontend/lib/models/api_models.dart` — API request/response models.
- Screens:
  - `frontend/lib/screens/enter_memory_screen.dart` — capture and save text memories.
  - `frontend/lib/screens/timeline_screen.dart` — browse memories by time and date.
  - `frontend/lib/screens/ask_ai_screen.dart` — ask the AI and see sourced memories.

## Requirements

### Backend

- Python 3.11+ recommended
- `pip install -r backend/requirements.txt`
- A valid `GOOGLE_API_KEY` in `backend/.env` for the Gemini RAG assistant.

> Note: `backend/.env.example` currently includes `OPENAI_API_KEY`, but the active query logic uses `GOOGLE_API_KEY`.

### Frontend

- Flutter SDK installed
- `flutter pub get` in the `frontend/` directory
- Run on device/emulator with `flutter run`

## Setup

### Backend

1. Open a terminal in `backend/`.
2. Install Python requirements:

```bash
pip install -r requirements.txt
```

3. Copy the example environment file:

```bash
cp .env.example .env
```

4. Edit `backend/.env` and add your `GOOGLE_API_KEY`.

5. Start the backend server:

```bash
uvicorn main:app --reload
```

6. API docs are available at `http://localhost:8000/docs`.

### Frontend

1. Open a terminal in `frontend/`.
2. Install Flutter packages:

```bash
flutter pub get
```

3. Run the app:

```bash
flutter run
```

4. For Android emulator networking, the app uses `10.0.2.2:8000` to reach the backend.

## Usage

- Capture new memories from the app and save them to the backend.
- Browse the `Life Replay` timeline to see stored memories sorted by date.
- Ask Vyra questions and receive answers grounded in your stored memories.

## Storage

- `backend/memories.json` — stores all memory metadata.
- `backend/faiss_index/index.faiss` — persists the FAISS embeddings index.

## Testing

Run the backend verification script in `backend/`:

```bash
python verify.py
```

## Notes

- Memory text is chunked at 500 characters with 50-character overlap before embedding.
- Each chunk is stored in FAISS and linked back to the parent memory.
- The app currently includes a placeholder recording toggle in the enter memory screen.

## Future Improvements

- Add full voice transcription using `whisper_ggml`.
- Support richer memory metadata and tone classification.
- Add authentication and encrypted storage.
- Extend the frontend with better memory detail views.
