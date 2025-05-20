# autenticacion/utils.py
import random
import smtplib
from email.mime.text import MIMEText



REMITENTE_EMAIL = 'porcytech@gmail.com'
CONTRASENA_APLICACION = 'yizmegkukuzobddt'

def generar_codigo_verificacion():
    import random
    return str(random.randint(100000, 999999))


def enviar_correo(destinatario, codigo, tipo="registro"):
    asunto = "🔒 Tu Código de Verificación - Acceso Seguro" if tipo == "registro" else "🔑 Recuperación de Contraseña"
    cuerpo = f"""
    <html>
    <body style="background-color:#1e1b28; color:#f0e442; font-family:Arial, sans-serif; padding:20px;">
        <h2 style="color:#9b59b6;">Código de Verificación</h2>
        <p>Hola, tu código es:</p>
        <h1 style="color:#f0e442;">{codigo}</h1>
        <p style="color:#ccc;">Por favor no compartas este código con nadie.</p>
    </body>
    </html>
    """
    mensaje = MIMEText(cuerpo, "html")
    mensaje["Subject"] = asunto
    mensaje["From"] = REMITENTE_EMAIL
    mensaje["To"] = destinatario

    try:
        with smtplib.SMTP_SSL('smtp.gmail.com', 465) as servidor:
            servidor.login(REMITENTE_EMAIL, CONTRASENA_APLICACION)
            servidor.sendmail(REMITENTE_EMAIL, destinatario, mensaje.as_string())
        return True
    except Exception as e:
        print(f"Error al enviar correo: {e}")
        return False
