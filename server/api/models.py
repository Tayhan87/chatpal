from django.db import models
from django.db.models import JSONField

class StudyMaterial(models.Model):
    title = models.CharField(max_length=255, blank=True)
    content_text = models.TextField(help_text="Text extracted from the PDF")
    
    def __str__(self):
        return self.title or "Untitled Material"

class Quiz(models.Model):
    study_material = models.ForeignKey(
        StudyMaterial, 
        on_delete=models.CASCADE, 
        related_name='quizzes'
    )
    title = models.CharField(max_length=255)
    
    def __str__(self):
        return self.title

class Question(models.Model):
    QUESTION_TYPES = (
        ('MCQ', 'Multiple Choice'),
    )

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

class QuestionAttempt(models.Model):
    question = models.ForeignKey(
        Question, 
        on_delete=models.CASCADE, 
        related_name='attempts'
    )
    student_answer = models.CharField(max_length=255)
    is_correct = models.BooleanField()

    def __str__(self):
        status = "Correct" if self.is_correct else "Incorrect"
        return f"Attempt on {self.question.id}: {status}"