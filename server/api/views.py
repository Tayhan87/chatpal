from django.shortcuts import render
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth.models import User
from rest_framework.authtoken.models import Token
from .serializers import LoginSerializer,SignUpSerializer
from rest_framework.permissions import AllowAny ,IsAuthenticated
import subprocess,requests
import re
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



@api_view(['POST'])
@permission_classes([AllowAny])
def get_data(request):
    incoming_messages = request.data.get("messages", [])
    print(f"Incoming messages: {incoming_messages}")

    try:
        genai.configure(api_key="AIzaSyDtSWC-XojFyFm4HhE-SUGc4_JOUsVlGNg")
        model = genai.GenerativeModel('gemini-flash-latest')

        if isinstance(incoming_messages, str):
            response = model.generate_content(incoming_messages)
            reply = response.text

        elif isinstance(incoming_messages, list):
            chat_history = []
            last_user_message = ""

            for msg in incoming_messages:
                role = msg.get('role')
                content = msg.get('content')
                
                if role == 'user':
                    last_user_message = content # Save the last prompt for generation
                    chat_history.append({'role': 'user', 'parts': [content]})
                elif role == 'assistant' or role == 'model':
                    chat_history.append({'role': 'model', 'parts': [content]})

            if chat_history and chat_history[-1]['role'] == 'user':
                last_user_message = chat_history.pop()['parts'][0]

            chat = model.start_chat(history=chat_history)
            response = chat.send_message(last_user_message)
            reply = response.text
        
        else:
            return Response({"error": "Invalid format for 'messages'."}, status=400)

        return Response({"message": reply})

    except Exception as e:
        print("Error:", str(e))
        return Response({"error": str(e)}, status=500)
    
    
            # Using OpenAI API
        # response = openai.ChatCompletion.create(
        #     model="gpt-3.5-turbo",  # or "gpt-4"
        #     messages=[{"role": "user", "content": prompt}],
        #     max_tokens=1000
        # )
        #ai_reply = response["choices"][0]["message"]["content"].strip()
    
    
    
# @api_view(["POST"])
# @permission_classes([AllowAny])
# def get_quizQuestions(request):
#     try:
#         pdf_file = request.FILES.get("File")
#         if not pdf_file:
#             return Response({"error": "No file uploaded."}, status=400)

#         reader = PdfReader(pdf_file)
#         text = "".join(page.extract_text() or "" for page in reader.pages)
#         if not text.strip():
#             return Response({"error": "The uploaded PDF contains no extractable text."}, status=400)

#         prompt = f"""
# You are an AI that extracts multiple-choice quiz questions from documents.

# I will provide you with a PDF. Your task is to:
# 1. Read and analyze the PDF content.
# 2. Identify key facts, concepts, or definitions suitable for quiz questions.
# 3. Generate multiple-choice questions with exactly 4 options each.
# 4. Minimum 5 questions should be generated.
# 5. Mark the correct answer clearly.
# 6. Return the output strictly in the following JSON format:

# {{
#   "questions": [
#     {{
#       "question": "string",
#       "options": ["option1", "option2", "option3", "option4"],
#       "answer": "string"
#     }}
#   ]
# }}

# Rules:
# - Do not include explanations or extra text outside the JSON.
# - Ensure the "answer" field matches exactly one of the options.
# - Keep questions concise and fact-based.

# Document content:
# {text}

# Respond ONLY with valid JSON. Do not include any text outside the JSON object.
# """
#         genai.configure(api_key="AIzaSyDtSWC-XojFyFm4HhE-SUGc4_JOUsVlGNg") 
#         model = genai.GenerativeModel("gemini-flash-latest")
#         response = model.generate_content(prompt)
#         ai_reply = response.text.strip()

        
#         if ai_reply.startswith("```"):
#             ai_reply = ai_reply.strip("`").replace("json", "").strip()

#         print("AI reply:", ai_reply)

#         if not ai_reply.startswith("{"):
#             return Response({"error": "API did not return JSON", "raw_reply": ai_reply}, status=500)

#         try:
#             quiz_data = json.loads(ai_reply)
#         except json.JSONDecodeError:
#             return Response({"error": "Invalid JSON returned by API", "raw_reply": ai_reply}, status=500)

#         if not isinstance(quiz_data.get("questions"), list):
#             return Response({"error": "API did not return a valid questions list"}, status=500)

        
#         for q in quiz_data["questions"]:
#             if not isinstance(q.get("options"), list) or len(q["options"]) != 4:
#                 return Response({"error": "Each question must have exactly 4 options"}, status=500)
#             if q.get("answer") not in q["options"]:
#                 return Response({"error": "Answer must match one of the options"}, status=500)

#         return Response(quiz_data)


    except Exception as e:
        return Response({"error": str(e)}, status=500)
    
@api_view(['GET'])
@permission_classes([AllowAny])
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
@permission_classes([AllowAny])
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
@permission_classes([AllowAny])
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
- Return VALID JSON only.
- If the text contains Math/LaTeX (like \\psi, \\alpha), you MUST double-escape backslashes (e.g., use "\\\\psi" not "\\psi").
- Do NOT use trailing commas.
- Do NOT use Markdown formatting.
-PLAIN TEXT ONLY. Do NOT use LaTeX or markdown formatting.

Document content:
{text_content}

Respond ONLY with valid JSON. Do not include any text outside the JSON object.
"""

        genai.configure(api_key="AIzaSyDtSWC-XojFyFm4HhE-SUGc4_JOUsVlGNg") 
        model = genai.GenerativeModel("gemini-flash-latest")
        response = model.generate_content(prompt)
        ai_reply = response.text.strip()
        print("AI reply:", ai_reply)

        try:
            # Step A: Strip Markdown blocks
            clean_text = ai_reply.replace("```json", "").replace("```", "").strip()
            
            clean_text = re.sub(r'\\(?![u"])', r'\\\\', clean_text)
            
            print(f"FIXED STRING: {clean_text}") # Debug print

            # Step C: Find and Parse JSON
            match = re.search(r'\{.*\}', clean_text, re.DOTALL)
            if match:
                final_json_string = match.group(0)
                quiz_data = json.loads(final_json_string)
            else:
                quiz_data = json.loads(clean_text)

        except json.JSONDecodeError as e:
            print(f"JSON PARSE ERROR: {e}")
            print(f"BAD STRING WAS: {clean_text}")
            return Response({"error": "Invalid JSON: " + str(e)}, status=500)
        
        quiz_title = f"Quiz for {material.title}"[:255]
        
        quiz_instance = Quiz.objects.create(
            study_material=material,
            title=quiz_title
        )

        response_questions_list = []

        for q in quiz_data["questions"]:
            if len(q.get("options", [])) != 4:
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
                "options": question_obj.options, # Django automatically gives us a list back
                "answer": question_obj.correct_answer
            })
            
        return Response({"questions": response_questions_list})

    except Exception as e:
        # This prints the ACTUAL error to your command prompt/terminal
        print("SERVER ERROR LOG:", str(e))
        return Response({"error": str(e)}, status=500)
    
    
@api_view(['POST'])    
@permission_classes([AllowAny])
def login_api(request):
    serializer = LoginSerializer(data=request.data)
    
    if not serializer.is_valid():
        return Response({
            'message': 'Invalid data', 
            'errors': serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)

    email = serializer.validated_data['email']
    password = serializer.validated_data['password']

    # Find user by email (standard Django auth expects username, so we query manually)
    try:
        user = User.objects.get(email=email)
    except User.DoesNotExist:
        return Response({
            'message': 'User with this email does not exist'
        }, status=status.HTTP_401_UNAUTHORIZED)

    # Check password
    if not user.check_password(password):
        return Response({
            'message': 'Invalid password'
        }, status=status.HTTP_401_UNAUTHORIZED)

    # If successful, generate or retrieve token
    token, created = Token.objects.get_or_create(user=user)

    return Response({
        'message': 'Login successful',
        'token': token.key,
        'user_id': user.pk,
        'email': user.email
    }, status=status.HTTP_200_OK)
    
    
@api_view(['POST'])
@permission_classes([AllowAny])
def signup_api(request):
    serializer = SignUpSerializer(data=request.data)
    
    if serializer.is_valid():
        # The serializer's create() method handles the User creation and hashing
        serializer.save()
        return Response({
            'message': 'Account created successfully!'
        }, status=status.HTTP_201_CREATED)
    
    # Return specific error messages (e.g., "Email already registered")
    return Response({
        'message': 'Sign up failed',
        'errors': serializer.errors
    }, status=status.HTTP_400_BAD_REQUEST)
    
    
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def logout_api(request):
    # Simply delete the token to force a login
    try:
        request.user.auth_token.delete()
        return Response({
            'message': 'Logged out successfully'
        }, status=status.HTTP_200_OK)
    except (AttributeError, Token.DoesNotExist):
        # Handle cases where user might be logged in but has no token (rare in this setup)
        return Response({
            'message': 'No active session found'
        }, status=status.HTTP_200_OK)
    

        
        
    
#find ip address - hostname -I
#python3 manage.py runserver 0.0.0.0:8000
#ALLOWED_HOSTS = ['192.168.0.105', 'localhost']
#source ../env/bin/activate


