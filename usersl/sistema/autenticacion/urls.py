from django.urls import path
from . import views

urlpatterns = [
    path('enviar_codigo/', views.enviar_codigo, name='enviar_codigo'),
    path('verificar_codigo/', views.verificar_codigo, name='verificar_codigo'),
    path('registrar_usuario/', views.registrar_usuario, name='registrar_usuario'),  # Cambié aquí
    path('login/', views.login, name='login'),
    path('enviar_codigo_recuperacion/', views.enviar_codigo_recuperacion, name='enviar_codigo_recuperacion'),
    path('cambiar_password/', views.cambiar_password, name='cambiar_password'),
]
