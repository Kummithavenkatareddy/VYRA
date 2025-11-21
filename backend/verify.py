import sys
import os

# Add the current directory (backend) to sys.path if running from backend/
# Or add backend/ to sys.path if running from root
current_dir = os.path.dirname(os.path.abspath(__file__))
if current_dir not in sys.path:
    sys.path.append(current_dir)

from fastapi.testclient import TestClient
from main import app

# Create a dummy .env if not exists for testing
if not os.path.exists(".env"):
    with open(".env", "w") as f:
        f.write("OPENAI_API_KEY=test")

client = TestClient(app)

def test_record_memory():
    response = client.post("/memory/record", json={"text": "I had a great day at the park!", "tone": "happy"})
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "saved"
    assert "memory_id" in data
    print("Record Memory: PASS")

def test_timeline():
    response = client.get("/timeline")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) > 0
    print("Timeline: PASS")

def test_ask():
    response = client.post("/ask", json={"query": "How was my day?"})
    assert response.status_code == 200
    data = response.json()
    assert "answer" in data
    assert "used_memories" in data
    print("Ask AI: PASS")

if __name__ == "__main__":
    print("Running Tests...")
    try:
        test_record_memory()
        test_timeline()
        test_ask()
        print("All tests passed!")
    except Exception as e:
        print(f"Test failed: {e}")
