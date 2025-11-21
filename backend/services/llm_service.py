import google.generativeai as genai
from backend.core.config import settings

class LLMService:
    def __init__(self):
        if settings.GOOGLE_API_KEY:
            genai.configure(api_key=settings.GOOGLE_API_KEY)
            self.model = genai.GenerativeModel('gemini-1.5-flash')
        else:
            self.model = None
            print("Warning: GOOGLE_API_KEY not found. LLM features will not work.")

    def generate_response(self, query: str, context: list) -> str:
        if not self.model:
            return "LLM not configured."
        
        context_str = "\n".join([f"- {item['text']}" for item in context])
        prompt = f"""
        You are an AI Memory Prosthetic. Use the following context to answer the user's question about their past.
        
        Context:
        {context_str}
        
        User Question: {query}
        
        Answer:
        """
        
        try:
            response = self.model.generate_content(prompt)
            return response.text
        except Exception as e:
            return f"Error generating response: {str(e)}"

llm_service = LLMService()
