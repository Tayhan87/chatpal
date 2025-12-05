from django.urls import path
from api import views

urlpatterns = [
    path('api/', views.get_data, name='get_data'),
    path('api/quiz/', views.get_quizQuestions, name='get_quizQuestions'),
    path('api/sentences/', views.get_pdf_titles, name='send_sentences'),
    path('api/makepdf/', views.make_pdf, name='make_pdf'),
    path("api/generate_quiz/", views.generate_quiz, name="generate_quiz"),
]