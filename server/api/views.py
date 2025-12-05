from django.shortcuts import render
from rest_framework.decorators import api_view
from rest_framework.response import Response
import subprocess,requests
from PyPDF2 import PdfReader
from dotenv import load_dotenv
import json
import openai
import google.generativeai as genai
import os
from api.models import *


url="http://localhost:11434/api/chat"

load_dotenv()
#openai.api_key = os.getenv("OPENAI_API_KEY")
#genai.configure(api_key=os.getenv("GEMINI_API_KEY"))
genai.configure(api_key="AIzaSyC54gw1l-n3AdjjOZS-NqU7_h__ZDs93Hw")



@api_view(['POST'])
def get_data(request):
    messages =request.data.get("messages",[])
    print(messages)
    
    
    try:
        response = requests.post(
            url,
            json ={
                "model":"phi",
                "messages":messages ,
                "stream":False,
            },
            stream=False
        )
        if response.status_code == 200:
            data=response.json()
            reply=data.get("message",{}).get("content","")
            return Response ({"message":reply})
        
        else:
            return Response ({"error":"Failed to get response from chat API"},status=500)
    except Exception as e:
        print("Error:",str(e))
        return Response ({"error":str(e)},status=500)
    
    
            # Using OpenAI API
        # response = openai.ChatCompletion.create(
        #     model="gpt-3.5-turbo",  # or "gpt-4"
        #     messages=[{"role": "user", "content": prompt}],
        #     max_tokens=1000
        # )
        #ai_reply = response["choices"][0]["message"]["content"].strip()
    
    
    
@api_view(["POST"])
def get_quizQuestions(request):
    try:
        pdf_file = request.FILES.get("File")
        if not pdf_file:
            return Response({"error": "No file uploaded."}, status=400)

        reader = PdfReader(pdf_file)
        text = "".join(page.extract_text() or "" for page in reader.pages)
        if not text.strip():
            return Response({"error": "The uploaded PDF contains no extractable text."}, status=400)

        prompt = f"""
You are an AI that extracts multiple-choice quiz questions from documents.

I will provide you with a PDF. Your task is to:
1. Read and analyze the PDF content.
2. Identify key facts, concepts, or definitions suitable for quiz questions.
3. Generate multiple-choice questions with exactly 4 options each.
4. Minimum 5 questions should be generated.
5. Mark the correct answer clearly.
6. Return the output strictly in the following JSON format:

{{
  "questions": [
    {{
      "question": "string",
      "options": ["option1", "option2", "option3", "option4"],
      "answer": "string"
    }}
  ]
}}

Rules:
- Do not include explanations or extra text outside the JSON.
- Ensure the "answer" field matches exactly one of the options.
- Keep questions concise and fact-based.

Document content:
{text}

Respond ONLY with valid JSON. Do not include any text outside the JSON object.
"""

        model = genai.GenerativeModel("gemini-flash-latest")
        response = model.generate_content(prompt)
        ai_reply = response.text.strip()

        
        if ai_reply.startswith("```"):
            ai_reply = ai_reply.strip("`").replace("json", "").strip()

        print("AI reply:", ai_reply)

        if not ai_reply.startswith("{"):
            return Response({"error": "API did not return JSON", "raw_reply": ai_reply}, status=500)

        try:
            quiz_data = json.loads(ai_reply)
        except json.JSONDecodeError:
            return Response({"error": "Invalid JSON returned by API", "raw_reply": ai_reply}, status=500)

        if not isinstance(quiz_data.get("questions"), list):
            return Response({"error": "API did not return a valid questions list"}, status=500)

        
        for q in quiz_data["questions"]:
            if not isinstance(q.get("options"), list) or len(q["options"]) != 4:
                return Response({"error": "Each question must have exactly 4 options"}, status=500)
            if q.get("answer") not in q["options"]:
                return Response({"error": "Answer must match one of the options"}, status=500)

        return Response(quiz_data)


    except Exception as e:
        return Response({"error": str(e)}, status=500)
    
@api_view(['GET'])
def get_pdf_titles(request):
    try:
        materials = StudyMaterial.objects.all().order_by('-id')
        data = [
            {"id": material.id, "title": material.title} 
            for material in materials
        ]
        return Response({"sentences": data})
    except Exception as e:
        return Response({"error": str(e)}, status=500)


@api_view(['POST'])
def make_pdf(request):
    try:
        pdf_file=request.FILES.get("pdf")
        if not pdf_file:
            return Response({"error": "No file uploaded."}, status=400)
        
        reader = PdfReader(pdf_file)
        text = "".join(page.extract_text() or "" for page in reader.pages)
        if not text.strip():
            return Response({"error": "The uploaded PDF contains no extractable text."}, status=400)
        
        study_material = StudyMaterial.objects.create(title=pdf_file.name,content_text=text)
        
        return Response({"message": "File stored successfully", "id": study_material.id}, status=201)
        
    except Exception as e:
        return Response ({"error":str(e)},status=500)
    
@api_view(['POST'])
def generate_quiz(request):
    try:
        
        doc_id = request.data.get("document_id")
        
        if not doc_id:
            return Response({"error": "document_id is required"}, status=400)
        try:
            material = StudyMaterial.objects.get(id=doc_id)
            text_content = material.content_text
        except StudyMaterial.DoesNotExist:
            return Response({"error": "Document not found"}, status=404)

        prompt = f"""
You are an AI that extracts multiple-choice quiz questions from documents.

I will provide you with text from a document. Your task is to:
1. Identify key facts, concepts, or definitions suitable for quiz questions.
2. Generate multiple-choice questions with exactly 4 options each.
3. Minimum 5 questions should be generated.
4. Mark the correct answer clearly.
5. Return the output strictly in the following JSON format:

{{
  "questions": [
    {{
      "question": "string",
      "options": ["option1", "option2", "option3", "option4"],
      "answer": "string"
    }}
  ]
}}

Rules:
- Do not include explanations or extra text outside the JSON.
- Ensure the "answer" field matches exactly one of the options.
- Keep questions concise and fact-based.

Document content:
{text_content}

Respond ONLY with valid JSON. Do not include any text outside the JSON object.
"""

        
        model = genai.GenerativeModel("gemini-flash-latest")
        response = model.generate_content(prompt)
        ai_reply = response.text.strip()

        
        if ai_reply.startswith("```"):
            ai_reply = ai_reply.strip("`").replace("json", "").strip()

        try:
            quiz_data = json.loads(ai_reply)
        except json.JSONDecodeError:
            return Response({"error": "Invalid JSON returned by API", "raw_reply": ai_reply}, status=500)

        if "questions" not in quiz_data:
            return Response({"error": "API did not return a valid questions list"}, status=500)

        
        quiz_instance = Quiz.objects.create(
            study_material=material,
            title=f"Quiz for {material.title}"
        )

        response_questions_list = []

        for q in quiz_data["questions"]:
        
            if len(q["options"]) != 4:
                continue 

            question_obj = Question.objects.create(
                quiz=quiz_instance,
                text=q["question"],
                options=q["options"], 
                correct_answer=q["answer"],
                question_type='MCQ'
            )

            response_questions_list.append({
                "id": question_obj.id,
                "question": question_obj.text,
                "options": question_obj.options,
                "answer": question_obj.correct_answer
            })
        return Response({"questions": response_questions_list})

    except Exception as e:
        return Response({"error": str(e)}, status=500)
    

        
        
    
#find ip address - hostname -I
#python3 manage.py runserver 0.0.0.0:8000
#ALLOWED_HOSTS = ['192.168.0.105', 'localhost']
#source ../env/bin/activate


