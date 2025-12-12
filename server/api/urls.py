from django.urls import path
from api import views

urlpatterns = [
    path('api/', views.get_data, name='get_data'),
   # path('api/quiz/', views.get_quizQuestions, name='get_quizQuestions'),
    path('api/pdf_titles/', views.get_pdf_titles, name='send_sentences'),
    path('api/makepdf/', views.make_pdf, name='make_pdf'),
    path("api/generate_quiz/", views.generate_quiz, name="generate_quiz"),
    path("api/login/", views.login_api, name="login"),
    path("api/signup/", views.signup_api, name="signup"),
    path("api/logout/", views.logout_api, name="logout"),
    path('api/delete_pdf/<int:doc_id>/', views.delete_pdf, name='delete_pdf'),
    path('api/generate_flashcards_from_doc/', views.generate_flashcards_from_doc, name='generate_flashcards'),
]