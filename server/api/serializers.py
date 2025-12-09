from rest_framework import serializers
from django.contrib.auth.models import User
from rest_framework.validators import UniqueValidator

class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField(required=True)
    password = serializers.CharField(required=True)
    

class SignUpSerializer(serializers.ModelSerializer):
    # Enforce unique email addresses
    email = serializers.EmailField(
        required=True,
        validators=[UniqueValidator(queryset=User.objects.all(), message="This email is already registered.")]
    )
    # Password must be at least 8 chars and is write-only (won't be sent back in response)
    password = serializers.CharField(write_only=True, required=True, min_length=8)
    name = serializers.CharField(required=True)

    class Meta:
        model = User
        fields = ('name', 'email', 'password')

    def create(self, validated_data):
        # We use email as the username to ensure uniqueness, as Django's default User model requires a username
        user = User.objects.create_user(
            username=validated_data['email'],
            email=validated_data['email'],
            password=validated_data['password'],
            first_name=validated_data['name']
        )
        return user