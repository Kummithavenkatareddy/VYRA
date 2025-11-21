def chunk_text(text: str, chunk_size: int = 500, overlap: int = 50) -> list[str]:
    """
    Simple chunking strategy.
    """
    if not text:
        return []
    
    chunks = []
    start = 0
    text_len = len(text)

    while start < text_len:
        end = start + chunk_size
        if end >= text_len:
            chunks.append(text[start:])
            break
        
        # Try to find the last space within the chunk to avoid splitting words
        last_space = text.rfind(' ', start, end)
        if last_space != -1 and last_space > start:
            end = last_space
        
        chunks.append(text[start:end])
        start = end - overlap
    
    return chunks
