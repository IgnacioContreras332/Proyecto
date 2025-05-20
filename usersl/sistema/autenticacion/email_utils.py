import smtplib
from email.mime.text import MIMEText

REMITENTE_EMAIL = 'porcytech@gmail.com'
CONTRASENA = 'yizmegkukuzobddt'

def enviar_correo(destinatario, codigo, tipo='registro'):
    asunto = "Código de verificación" if tipo == 'registro' else "Recuperación de contraseña"
    cuerpo = f"""<html><body><h2>{asunto}</h2><p>Código: <strong>{codigo}</strong></p></body></html>"""

    mensaje = MIMEText(cuerpo, "html")
    mensaje["Subject"] = asunto
    mensaje["From"] = REMITENTE_EMAIL
    mensaje["To"] = destinatario

    try:
        with smtplib.SMTP_SSL('smtp.gmail.com', 465) as servidor:
            servidor.login(REMITENTE_EMAIL, CONTRASENA)
            servidor.sendmail(REMITENTE_EMAIL, destinatario, mensaje.as_string())
        return True
    except Exception as e:
        print("Error al enviar:", e)
        return False
