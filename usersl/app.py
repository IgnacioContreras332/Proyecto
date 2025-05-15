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

def enviar_correo(destinatario, codigo):
    asunto = 'Tu Código de Verificación'
    cuerpo = f'Tu código de verificación es: {codigo}'
    mensaje = MIMEText(cuerpo)
    mensaje['Subject'] = asunto
    mensaje['From'] = REMITENTE_EMAIL
    mensaje['To'] = destinatario

    try:
        with smtplib.SMTP_SSL('smtp.gmail.com', 465) as servidor:
            servidor.login(REMITENTE_EMAIL, CONTRASENA_APLICACION)
            servidor.sendmail(REMITENTE_EMAIL, destinatario, mensaje.as_string())
        return True
    except Exception as e:
        print(f"❌ Error al enviar correo: {e}")
        return False

@app.route('/enviar_codigo', methods=['POST'])
def enviar_codigo():
    data = request.get_json()
    email = data.get('destinatario_email')

    print(f"🔎 Recibido en Flask: {data}")  # ✅ Depuración

    if not email:
        return jsonify({"error": "Correo requerido"}), 400

    codigo = generar_codigo_verificacion()
    verification_codes[email] = codigo

    if enviar_correo(email, codigo):
        return jsonify({"mensaje": "Código enviado correctamente"}), 200
    return jsonify({"error": "Error al enviar código"}), 500

@app.route('/registrar_usuario', methods=['POST'])
def registrar_usuario():
    data = request.get_json()
    email, codigo, password, name = data.get('email'), data.get('codigo'), data.get('password'), data.get('name')

    print(f"🔎 Registrando usuario: {data}")  # ✅ Depuración

    if verification_codes.get(email) != codigo:
        return jsonify({"error": "Código de verificación incorrecto"}), 400

    conn = conectar_db()
    if not conn:
        return jsonify({"error": "Error de conexión a la BD"}), 500

    cursor = conn.cursor()
    cursor.execute("SELECT id FROM users WHERE email = %s;", (email,))
    if cursor.fetchone():
        conn.close()
        return jsonify({"error": "Correo ya registrado"}), 400

    cursor.execute("INSERT INTO users (email, name, password) VALUES (%s, %s, %s)", (email, name, password))
    conn.commit()
    conn.close()

    del verification_codes[email]  # ✅ Eliminamos el código una vez registrado
    return jsonify({"mensaje": f"Usuario {email} registrado exitosamente"}), 200

@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    email, password = data.get('email'), data.get('password')

    print(f"🔎 Recibido en Flask: Email={email}, Password={password}")  # ✅ Depuración

    conn = conectar_db()
    if not conn:
        return jsonify({"error": "Error de conexión a la BD"}), 500

    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT password FROM users WHERE email = %s;", (email,))
    usuario = cursor.fetchone()
    conn.close()

    print(f"🔍 Datos en BD: {usuario}")  # ✅ Depuración

    if usuario and usuario['password'] == password:
        return jsonify({"mensaje": "Inicio de sesión exitoso"}), 200
    else:
        print(f"❌ Credenciales incorrectas: BD={usuario['password']} | Usuario ingresó={password}")  
        return jsonify({"error": "Correo o contraseña incorrecta"}), 401

@app.route('/enviar_codigo_recuperacion', methods=['POST'])
def enviar_codigo_recuperacion():
    data = request.get_json()
    email = data.get('email')

    print(f"🔎 Recibido en Flask: {data}")  # ✅ Depuración

    if not email:
        return jsonify({"error": "Correo requerido"}), 400

    conn = conectar_db()
    if not conn:
        return jsonify({"error": "Error de conexión a la BD"}), 500

    cursor = conn.cursor()
    cursor.execute("SELECT id FROM users WHERE email = %s;", (email,))
    usuario = cursor.fetchone()
    conn.close()

    if not usuario:
        return jsonify({"error": "Correo no registrado"}), 404

    codigo = generar_codigo_verificacion()
    verification_codes[email] = codigo

    if enviar_correo(email, codigo):
        return jsonify({"mensaje": "Código de recuperación enviado"}), 200
    return jsonify({"error": "Error al enviar código"}), 500

@app.route('/cambiar_password', methods=['POST'])
def cambiar_password():
    data = request.get_json()
    email, codigo, password = data.get('email'), data.get('codigo'), data.get('password')

    if not email or not codigo or not password:
        return jsonify({"error": "Todos los campos son obligatorios"}), 400

    if verification_codes.get(email) != codigo:
        return jsonify({"error": "Código incorrecto"}), 400

    conn = conectar_db()
    if not conn:
        return jsonify({"error": "Error de conexión a la BD"}), 500

    cursor = conn.cursor()
    cursor.execute("UPDATE users SET password = %s WHERE email = %s", (password, email))
    conn.commit()
    conn.close()

    del verification_codes[email]  
    return jsonify({"mensaje": "Contraseña actualizada correctamente"}), 200

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)