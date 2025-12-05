import os
import openai
import google.generativeai as genai
from dotenv import load_dotenv

# Load .env file
load_dotenv()

#openai.api_key = os.getenv("OPENAI_API_KEY")
genai.configure(api_key=os.getenv("GEMINI_API_KEY"))

try:
    # Test OpenAI API key
    # response = openai.ChatCompletion.create(
    #     model="gpt-3.5-turbo",
    #     messages=[{"role": "user", "content": "Say hello"}],
    #     max_tokens=10
    # )
    #print("Response:", response["choices"][0]["message"]["content"])
    
    
    #Test Gemini API key
    model = genai.GenerativeModel("gemini-flash-latest")
    
    response = model.generate_content("Say hello")
    
    print("✅ API key works!")
    print("Response:", response.text) 
    
except Exception as e:
    print("❌ API key error:", e)
