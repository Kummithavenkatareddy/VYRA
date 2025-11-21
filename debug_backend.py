import sys
import os
import traceback

# Ensure we can import backend modules
sys.path.append(os.getcwd())

try:
    print("Importing MemoryService...")
    from backend.services.memory_service import memory_service
    print("MemoryService imported successfully.")

    print("Attempting to add memory...")
    memory_id = memory_service.add_memory(
        text="Debug memory entry",
        metadata={"user_id": "debug_user", "timestamp": "2023-01-01"}
    )
    print(f"Success! Memory ID: {memory_id}")

except Exception:
    print("\n!!! ERROR OCCURRED !!!\n")
    traceback.print_exc()
