from django.contrib import admin
from api.models import *
# Register your models here.

admin.site.register(Quiz)
admin.site.register(Question)
admin.site.register(StudyMaterial)
admin.site.register(QuestionAttempt)
admin.site.register(FlashCard)

