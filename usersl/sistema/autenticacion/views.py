from django.views.decorators.csrf import csrf_exempt
from django.http import JsonResponse
from django.utils.decorators import method_decorator
from .models import Usuario
from .email_utils import enviar_correo
import json, random
from django.http import JsonResponse, HttpResponseBadRequest
from django.views.decorators.csrf import csrf_exempt
import json
from .utils import generar_codigo_verificacion, enviar_correo


from django.core.mail import EmailMultiAlternatives
from django.template.loader import render_to_string
from django.conf import settings

# tus otras importaciones y funciones...

codigos = {}

def generar_codigo():
    return str(random.randint(100000, 999999))


@csrf_exempt
def enviar_codigo(request):
    if request.method != 'POST':
        return HttpResponseBadRequest("Solo se permite método POST")

    try:
        data = json.loads(request.body)
    except json.JSONDecodeError:
        return HttpResponseBadRequest("JSON inválido o vacío")

    email = data.get("email")
    if not email:
        return HttpResponseBadRequest("Falta el campo email")

    codigo = generar_codigo_verificacion()  # Aquí se llama a la función que debes importar

    codigos[email] = codigo  # Si tienes este dict para guardar códigos temporalmente

    if enviar_correo(email, codigo, tipo="registro"):
        return JsonResponse({"mensaje": "Código enviado correctamente"})
    else:
        return JsonResponse({"error": "Error al enviar el correo"}, status=500)

@csrf_exempt
def verificar_codigo(request):
    data = json.loads(request.body)
    email = data.get("email")
    codigo = data.get("codigo")
    if codigos.get(email) == codigo:
        return JsonResponse({"mensaje": "Código correcto"})
    return JsonResponse({"error": "Código incorrecto"}, status=400)


@csrf_exempt
def registrar_usuario(request):
    if request.method != "POST":
        return HttpResponseBadRequest("Solo se permite POST")

    try:
        print("Request body raw:", request.body)  # Esto te muestra el body en bytes
        data = json.loads(request.body)
        print("Parsed JSON data:", data)
    except json.JSONDecodeError:
        print("Error: JSON inválido")
        return HttpResponseBadRequest("JSON inválido")

    email = data.get("email")
    name = data.get("name")
    password = data.get("password")
    codigo = data.get("codigo")

    print(f"Campos recibidos - email: {email}, name: {name}, password: {password}, codigo: {codigo}")

    if not email or not name or not password or not codigo:
        print("Error: Faltan campos requeridos")
        return HttpResponseBadRequest("Faltan campos requeridos")

    if codigos.get(email) != codigo:
        print("Error: Código incorrecto")
        return JsonResponse({"error": "Código incorrecto"}, status=400)

    if Usuario.objects.filter(email=email).exists():
        print("Error: Correo ya registrado")
        return JsonResponse({"error": "Correo ya registrado"}, status=400)

    Usuario.objects.create(email=email, name=name, password=password)
    if email in codigos:
        del codigos[email]

    print("Usuario registrado correctamente")
    return JsonResponse({"mensaje": "Usuario registrado correctamente"})


@csrf_exempt
def login(request):
    data = json.loads(request.body)
    email = data.get("email")
    password = data.get("password")

    try:
        usuario = Usuario.objects.get(email=email)
        if usuario.password == password:
            return JsonResponse({"mensaje": "Login exitoso"})
        return JsonResponse({"error": "Contraseña incorrecta"}, status=401)
    except Usuario.DoesNotExist:
        return JsonResponse({"error": "Usuario no encontrado"}, status=404)

@csrf_exempt
def enviar_codigo_recuperacion(request):
    data = json.loads(request.body)
    email = data.get("email")
    if not Usuario.objects.filter(email=email).exists():
        return JsonResponse({"error": "Correo no registrado"}, status=404)
    codigo = generar_codigo()
    codigos[email] = codigo
    if enviar_correo(email, codigo, tipo="recuperacion"):
        return JsonResponse({"mensaje": "Código enviado correctamente"})
    return JsonResponse({"error": "Error al enviar el correo"}, status=500)

@csrf_exempt
def cambiar_password(request):
    data = json.loads(request.body)
    email = data.get("email")
    codigo = data.get("codigo")
    password = data.get("password")
    if codigos.get(email) != codigo:
        return JsonResponse({"error": "Código incorrecto"}, status=400)
    try:
        usuario = Usuario.objects.get(email=email)
        usuario.password = password
        usuario.save()
        del codigos[email]
        return JsonResponse({"mensaje": "Contraseña actualizada correctamente"})
    except Usuario.DoesNotExist:
        return JsonResponse({"error": "Usuario no encontrado"}, status=404)


def enviar_correo_confirmacion(email_destino, contexto):
    # Renderizas el template HTML con el contexto que quieras pasar
    html_content = render_to_string('codigo_confirmacion.html', contexto)

    # Puedes crear también la versión en texto plano para clientes que no leen HTML
    text_content = 'Gracias por registrarte en nuestro sitio.'

    email = EmailMultiAlternatives(
        subject='Confirma tu registro',
        body=text_content,
        from_email=settings.DEFAULT_FROM_EMAIL,
        to=[email_destino],
    )
    email.attach_alternative(html_content, "text/html")
    email.send()
