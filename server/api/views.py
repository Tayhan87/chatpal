from django.shortcuts import render
from rest_framework.decorators import api_view
from rest_framework.response import Response
import subprocess,requests

@api_view(['POST'])
def get_data(request):
    messages =request.data.get("messages",[])
    print(messages)
    url="http://localhost:11434/api/chat"
    
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
        
    
#find ip address - hostname -I
#python manage.py runserver 0.0.0.0:8000
#ALLOWED_HOSTS = ['192.168.0.105', 'localhost']


# Create your views here.
