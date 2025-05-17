from flask import Flask, request, jsonify
from flask_cors import CORS
import random
import smtplib
from email.mime.text import MIMEText
from db import conectar_db

app = Flask(__name__)
CORS(app)

REMITENTE_EMAIL = 'porcytech@gmail.com'
CONTRASENA_APLICACION = 'yizmegkukuzobddt'
verification_codes = {}

def generar_codigo_verificacion():
    return str(random.randint(100000, 999999))

def enviar_correo(destinatario, codigo, tipo="registro"):
    asunto = "🔒 Tu Código de Verificación - Acceso Seguro" if tipo == "registro" else "🔑 Recuperación de Contraseña"
    cuerpo = f"""
    <html>
    <body style="font-family: Arial, sans-serif; color: #fff; background-color: #4B0082; padding: 20px; border-radius: 10px;">
        <div style="max-width: 500px; margin: auto; background: #6A0DAD; padding: 20px; border-radius: 10px;">
            <h2 style="color: #FFD700; text-align: center;">{"¡Bienvenido a nuestra comunidad!" if tipo == "registro" else "🔑 Recuperación de Contraseña"}</h2>
            <p style="text-align: center;">{"Gracias por registrarte. Estamos emocionados de que formes parte de nuestra plataforma." if tipo == "registro" else "Has solicitado cambiar tu contraseña."}</p>
            <hr style="border: 1px solid #FFD700;">
            <p style="text-align: center;">{"Para empezar, confirma tu correo con el siguiente código:" if tipo == "registro" else "Usa el siguiente código para recuperar tu acceso:"}</p>
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
        with smtplib.SMTP_SSL('smtp.gmail.com', 465) as servidor:
            servidor.login(REMITENTE_EMAIL, CONTRASENA_APLICACION)
            servidor.sendmail(REMITENTE_EMAIL, destinatario, mensaje.as_string())
        print(f"✅ Correo enviado correctamente a {destinatario}")
        return True
    except Exception as e:
        print(f"❌ Error exacto al enviar correo: {e}")
        return False

@app.route('/enviar_codigo_recuperacion', methods=['POST'])
def enviar_codigo_recuperacion():
    if "application/json" not in request.content_type:
        print(f"❌ Content-Type recibido: {request.content_type}")  # Depuración extra
        return jsonify({"error": "El Content-Type debe ser 'application/json'"}), 415
    
    data = request.get_json()
    email = data.get('email')

    print(f"🔎 Recibido en Flask: {data}")  # Depuración

    if not email:
        return jsonify({"error": "Correo requerido"}), 400

    conn = conectar_db()
    cursor = conn.cursor()
    cursor.execute("SELECT id FROM users WHERE email = %s;", (email,))
    usuario = cursor.fetchone()
    conn.close()

    if not usuario:
        return jsonify({"error": "Correo no registrado"}), 404

    codigo = generar_codigo_verificacion()
    verification_codes[email] = codigo

    if enviar_correo(email, codigo, tipo="recuperacion"): # Aquí se especifica el tipo
        print(f"✅ Código de recuperación enviado a {email}")  # Depuración de éxito
        return jsonify({"mensaje": "Código de recuperación enviado correctamente"}), 200
    else:
        print(f"❌ Error al enviar código de recuperación a {email}")  # Depuración de fallo
        return jsonify({"error": "Error al enviar código"}), 500


@app.route('/cambiar_password', methods=['POST'])
def cambiar_password():
    if "application/json" not in request.content_type:
        print(f"❌ Content-Type recibido: {request.content_type}")  # Depuración extra
        return jsonify({"error": "El Content-Type debe ser 'application/json'"}), 415
    
    data = request.get_json()
    email, codigo, password = data.get('email'), data.get('codigo'), data.get('password')

    print(f"🔎 Cambiando contraseña: Email={email}, Código={codigo}, Nueva Password={password}")  # Depuración

    if not email or not codigo or not password:
        return jsonify({"error": "Todos los campos son obligatorios"}), 400

    if verification_codes.get(email) != codigo:
        return jsonify({"error": "Código incorrecto"}), 400

    conn = conectar_db()
    cursor = conn.cursor()
    cursor.execute("UPDATE users SET password = %s WHERE email = %s", (password, email))
    conn.commit()
    conn.close()

    del verification_codes[email]  
    print(f"✅ Contraseña actualizada para {email}")  # Depuración de éxito
    return jsonify({"mensaje": "Contraseña actualizada correctamente"}), 200

@app.route('/enviar_codigo', methods=['POST'])
def enviar_codigo():
    if "application/json" not in request.content_type:
        return jsonify({"error": "El Content-Type debe ser 'application/json'"}), 415

    data = request.get_json()
    email = data.get('email')

    print(f"🔎 Recibido en Flask: {data}")  # Depuración

    if not email:
        return jsonify({"error": "Correo requerido"}), 400

    codigo = generar_codigo_verificacion()
    verification_codes[email] = codigo

    if enviar_correo(email, codigo, tipo="registro"): # Aquí se especifica el tipo
        return jsonify({"mensaje": "Código enviado correctamente"}), 200
    return jsonify({"error": "Error al enviar código"}), 500

@app.route('/verificar_codigo', methods=['POST'])
def verificar_codigo():
    if "application/json" not in request.content_type:
        return jsonify({"error": "El Content-Type debe ser 'application/json'"}), 415

    data = request.get_json()
    email = data.get('email')
    codigo = data.get('codigo')

    print(f"🔎 Verificando código para {email}: Código recibido={codigo}, Código guardado={verification_codes.get(email)}")  # Depuración

    if not email or not codigo:
        return jsonify({"error": "Email y código son obligatorios"}), 400

    if verification_codes.get(email) == codigo:
        return jsonify({"mensaje": "Código correcto"}), 200
    else:
        return jsonify({"error": "Código incorrecto"}), 400

@app.route('/registrar_usuario', methods=['POST'])
def registrar_usuario():
    if "application/json" not in request.content_type:
        return jsonify({"error": "El Content-Type debe ser 'application/json'"}), 415

    data = request.get_json()
    email = data.get('email')
    codigo = data.get('codigo')
    password = data.get('password')
    name = data.get('name')

    print(f"🔎 Registrando usuario: {email} con código {codigo}")  # Depuración

    if not email or not codigo or not password or not name:
        return jsonify({"error": "Todos los campos son obligatorios"}), 400

    if verification_codes.get(email) != codigo:
        return jsonify({"error": "Código incorrecto"}), 400

    conn = conectar_db()
    cursor = conn.cursor()
    cursor.execute("SELECT id FROM users WHERE email = %s;", (email,))
    if cursor.fetchone():
        conn.close()
        return jsonify({"error": "Correo ya registrado"}), 400

    cursor.execute("INSERT INTO users (email, name, password) VALUES (%s, %s, %s)", (email, name, password))
    conn.commit()
    conn.close()

    del verification_codes[email]  
    print(f"✅ Usuario {email} registrado exitosamente")  # Confirmación
    return jsonify({"mensaje": "Usuario registrado correctamente"}), 200

@app.route('/login', methods=['POST'])
def login():
    if "application/json" not in request.content_type:
        return jsonify({"error": "El Content-Type debe ser 'application/json'"}), 415

    data = request.get_json()
    email = data.get('email')
    password = data.get('password')

    print(f"🔎 Intento de login: Email={email}, Password={password}")  # Depuración

    if not email or not password:
        return jsonify({"error": "Email y contraseña requeridos"}), 400

    conn = conectar_db()
    cursor = conn.cursor()
    cursor.execute("SELECT password FROM users WHERE email = %s;", (email,))
    user = cursor.fetchone()
    conn.close()

    if not user:
        return jsonify({"error": "Usuario no encontrado"}), 404

    if user[0] == password:  
        return jsonify({"mensaje": "Login exitoso"}), 200
    else:
        return jsonify({"error": "Contraseña incorrecta"}), 401

@app.route('/usuario/<email>', methods=['GET'])
def obtener_usuario(email):
    print(f"🔎 Petición recibida en Flask: /usuario/{email}")  # Ver qué datos llegan
    
    conn = conectar_db()
    cursor = conn.cursor()
    cursor.execute("SELECT id, email, name FROM users WHERE email = %s;", (email,))
    usuario = cursor.fetchone()
    conn.close()

    if not usuario:
        print(f"❌ Usuario no encontrado: {email}")  # Ver si la consulta falla
        return jsonify({"error": "Usuario no encontrado"}), 404

    print(f"✅ Usuario encontrado: {usuario}")  # Ver datos recuperados
    return jsonify({
        "id": usuario[0],
        "email": usuario[1],
        "name": usuario[2]
    }), 200

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
