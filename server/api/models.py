from django.db import models
from django.conf import settings

class StudyMaterial(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='study_materials', null=True,  blank=True)
    title = models.CharField(max_length=255, blank=True)
    content_text = models.TextField(help_text="Text extracted from the PDF")
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        username = self.user.username if self.user else "Unknown User"
        return f"{self.title} ({username})"


class Quiz(models.Model):
    study_material = models.ForeignKey(
        StudyMaterial, 
        on_delete=models.CASCADE, 
        related_name='quizzes'
    )
    title = models.CharField(max_length=255)
    created_at = models.DateTimeField(auto_now_add=True)  # ADD THIS LINE
    
    def __str__(self):
        return self.title


class Question(models.Model):
    QUESTION_TYPES = (('MCQ', 'Multiple Choice'),)

    quiz = models.ForeignKey(
        Quiz, 
        on_delete=models.CASCADE, 
        related_name='questions'
    )
    text = models.TextField()
    question_type = models.CharField(max_length=3, choices=QUESTION_TYPES, default='MCQ')
    options = models.JSONField(default=list, blank=True)
    correct_answer = models.CharField(max_length=255)
    explanation = models.TextField(blank=True, null=True)

    def __str__(self):
        return f"{self.text[:50]}..."
    

class FlashCard(models.Model):
    study_material = models.ForeignKey(StudyMaterial, on_delete=models.CASCADE, related_name='flashcards')
    front = models.TextField(help_text="The question or concept")
    back = models.TextField(help_text="The answer or definition")
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.front[:30]}..."


class QuestionAttempt(models.Model):
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='attempts',
        null=True,
        blank=True
    )
    question = models.ForeignKey(
        Question, 
        on_delete=models.CASCADE, 
        related_name='attempts'
    )
    student_answer = models.CharField(max_length=255)
    is_correct = models.BooleanField()
    timestamp = models.DateTimeField(auto_now_add=True, null=True) 

    def __str__(self):
        status = "Correct" if self.is_correct else "Incorrect"
        username = self.user.username if self.user else "Unknown"
        return f"{username} - {self.question.id}: {status}"