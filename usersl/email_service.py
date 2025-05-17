# email_services.py
import smtplib
from email.mime.text import MIMEText

REMITENTE_EMAIL = 'porcytech@gmail.com'
CONTRASENA_APLICACION = 'yizmegkukuzobddt'

def enviar_correo_registro(destinatario, codigo):
    """Envía un correo electrónico de bienvenida y código de verificación para el registro."""
    asunto = "🔒 Tu Código de Verificación - Acceso Seguro"
    cuerpo = f"""
    <html>
    <body style="font-family: Arial, sans-serif; color: #fff; background-color: #4B0082; padding: 20px;">
        <div style="max-width: 500px; margin: auto; background: #6A0DAD; padding: 20px; border-radius: 10px;">
            <h2 style="color: #FFD700; text-align: center;">¡Bienvenido a nuestra comunidad!</h2>
            <p style="text-align: center;">Gracias por registrarte. Estamos emocionados de que formes parte de nuestra plataforma.</p>
            <hr style="border: 1px solid #FFD700;">
            <p style="text-align: center;">Para empezar, confirma tu correo con el siguiente código:</p>
            <p style="font-size: 22px; text-align: center; font-weight: bold; color: #FFD700;">{codigo}</p>
            <p style="text-align: center;">Este código expirará en <strong>10 minutos</strong>.</p>
            <hr style="border: 1px solid #FFD700;">
            <p style="text-align: center;">Si no realizaste esta acción, por favor ignora este mensaje.</p>
        </div>
        <p style="text-align: center; font-size: 12px; color: #ccc;">Este es un mensaje automático, no respondas.</p>
    </body>
    </html>
    """
    mensaje = MIMEText(cuerpo, "html")
    mensaje["Subject"] = asunto
    mensaje["From"] = REMITENTE_EMAIL
    mensaje["To"] = destinatario

    try:
        with smtplib.SMTP_SSL("smtp.gmail.com", 465) as servidor:
            servidor.login(REMITENTE_EMAIL, CONTRASENA_APLICACION)
            servidor.sendmail(REMITENTE_EMAIL, destinatario, mensaje.as_string())
        print(f"✅ Correo de registro enviado correctamente a {destinatario}")
        return True
    except Exception as e:
        print(f"❌ Error exacto al enviar correo de registro: {e}")
        return False


def enviar_correo_recuperacion(destinatario, codigo):
    """Envía un correo electrónico con el código de recuperación de contraseña."""
    asunto = "🔑 Recuperación de Contraseña"
    cuerpo = f"""
    <html>
    <body style="font-family: Arial, sans-serif; color: #fff; background-color: #4B0082; padding: 20px;">
        <div style="max-width: 500px; margin: auto; background: #6A0DAD; padding: 20px; border-radius: 10px;">
            <h2 style="color: #FFD700; text-align: center;">🔑 Recuperación de Contraseña</h2>
            <p style="text-align: center;">Has solicitado cambiar tu contraseña.</p>
            <hr style="border: 1px solid #FFD700;">
            <p style="text-align: center;">Usa el siguiente código para recuperar tu acceso:</p>
            <p style="font-size: 22px; text-align: center; font-weight: bold; color: #FFD700;">{codigo}</p>
            <p style="text-align: center;">Este código expirará en <strong>10 minutos</strong>.</p>
            <hr style="border: 1px solid #FFD700;">
            <p style="text-align: center;">Si no realizaste esta acción, por favor ignora este mensaje.</p>
        </div>
        <p style="text-align: center; font-size: 12px; color: #ccc;">Este es un mensaje automático, no respondas.</p>
    </body>
    </html>
    """
    mensaje = MIMEText(cuerpo, "html")
    mensaje["Subject"] = asunto
    mensaje["From"] = REMITENTE_EMAIL
    mensaje["To"] = destinatario

    try:
        with smtplib.SMTP_SSL("smtp.gmail.com", 465) as servidor:
            servidor.login(REMITENTE_EMAIL, CONTRASENA_APLICACION)
            servidor.sendmail(REMITENTE_EMAIL, destinatario, mensaje.as_string())
        print(f"✅ Correo de recuperación enviado correctamente a {destinatario}")
        return True
    except Exception as e:
        print(f"❌ Error exacto al enviar correo de recuperación: {e}")
        return False
