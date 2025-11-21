import requests
import json

BASE_URL = "http://127.0.0.1:8000"
USER_ID = "test_user_123"

def test_endpoints():
    print("Starting API Tests...")
    
    memory_id = None

    # 1. Test Text Memory Creation
    print("\n--- Testing Text Memory Endpoint ---")
    try:
        payload = {
            "user_id": USER_ID,
            "text": "I felt really happy today because I finished my project early.",
            "timestamp": "2023-10-27T10:00:00"
        }
        response = requests.post(f"{BASE_URL}/api/v1/memories", json=payload)
        response.raise_for_status()
        data = response.json()
        memory_id = data.get("id")
        print(f"Memory Created: {memory_id}")
        print(f"Response: {data}")
    except requests.exceptions.RequestException as e:
        print(f"Error creating text memory: {e}")
        return

    if not memory_id:
        print("Skipping dependent tests because memory creation failed.")
        return

    # 2. Test Memory Detail
    print("\n--- Testing Memory Detail Endpoint ---")
    try:
        response = requests.get(f"{BASE_URL}/api/v1/memories/{memory_id}")
        response.raise_for_status()
        print(f"Memory Detail: {response.json()}")
    except requests.exceptions.RequestException as e:
        print(f"Error fetching memory detail: {e}")

    # 3. Test Timeline
    print("\n--- Testing Timeline Endpoint ---")
    try:
        response = requests.get(f"{BASE_URL}/api/v1/memories", params={"user_id": USER_ID})
        response.raise_for_status()
        print(f"Timeline: {response.json()}")
    except requests.exceptions.RequestException as e:
        print(f"Error fetching timeline: {e}")

    # 4. Test Query (RAG)
    print("\n--- Testing Query Endpoint ---")
    try:
        query_payload = {
            "user_id": USER_ID,
            "question": "What did I feel on that day?"
        }
        response = requests.post(f"{BASE_URL}/api/v1/query", json=query_payload)
        response.raise_for_status()
        print(f"Query Answer: {response.json()}")
    except requests.exceptions.RequestException as e:
        print(f"Error querying: {e}")

    # 5. Test Audio Memory (Mock)
    print("\n--- Testing Audio Memory Endpoint ---")
    try:
        # Create a dummy file
        files = {
            'file': ('test_audio.mp3', b'dummy audio content', 'audio/mpeg')
        }
        data = {'user_id': USER_ID}
        response = requests.post(f"{BASE_URL}/api/v1/memories/audio", files=files, data=data)
        response.raise_for_status()
        print(f"Audio Memory Created: {response.json()}")
    except requests.exceptions.RequestException as e:
        print(f"Error uploading audio: {e}")

if __name__ == "__main__":
    test_endpoints()
