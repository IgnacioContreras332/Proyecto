import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static const String baseUrl = 'http://192.168.0.182:5000';

  // 📩 Enviar código de verificación al correo
  static Future<bool> enviarCodigo(String email) async {
    try {
      debugPrint('🔎 Enviando código de verificación: Email=$email');

      final response = await http.post(
        Uri.parse('$baseUrl/enviar_codigo'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email.trim()}),
      );

      debugPrint('🔍 Respuesta de Flask: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Error al enviar código: $e');
      return false;
    }
  }

  // 📝 Registrar usuario en MySQL vía Flask con código de verificación
  static Future<bool> registrarUsuario({
    required String email,
    required String codigo,
    required String password,
    required String name,
  }) async {
    try {
      debugPrint('🔎 Enviando registro: Email=$email');

      final response = await http.post(
        Uri.parse('$baseUrl/registrar_usuario'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email.trim(),
          "codigo": codigo.trim(),
          "password": password.trim(), // ✅ SIN encriptación
          "name": name.trim(),
        }),
      );

      debugPrint('🔍 Respuesta de Flask: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Error en registro: $e');
      return false;
    }
  }

  // 🔑 Inicio de sesión en MySQL
  static Future<bool> login({required String email, required String password}) async {
    try {
      debugPrint('🔎 Enviando login: Email=$email, Password=$password');

      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email.trim(), "password": password.trim()}), // ✅ SIN encriptación
      );

      debugPrint('🔍 Respuesta de Flask: ${response.body}');

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userEmail', email.trim());
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error en login: $e');
      return false;
    }
  }

  // 📨 Enviar código de recuperación de contraseña
  static Future<bool> enviarCodigoRecuperacion(String email) async {
  try {
    debugPrint('🔎 Enviando código de recuperación: Email=$email');

    final response = await http.post(
      Uri.parse('$baseUrl/enviar_codigo_recuperacion'),
      headers: {
        "Content-Type": "application/json",  // ✅ Eliminamos `charset=utf-8`
        "Accept": "application/json" // 🔧 Aseguramos que Flask acepte JSON
      },
      body: jsonEncode({"email": email.trim()}),
    );

    debugPrint('🔍 Respuesta de Flask: ${response.body}');
    return response.statusCode == 200;
  } catch (e) {
    debugPrint('❌ Error al enviar código de recuperación: $e');
    return false;
  }
}

  // 🔄 Cambiar la contraseña después de verificación
  static Future<bool> cambiarPassword({
  required String email,
  required String codigo,
  required String nuevaPassword,
}) async {
  try {
    debugPrint('🔎 Enviando cambio de contraseña: Email=$email');

    final response = await http.post(
      Uri.parse('$baseUrl/cambiar_password'),
      headers: {
        "Content-Type": "application/json",  // ✅ Eliminamos `charset=utf-8`
        "Accept": "application/json" // 🔧 Aseguramos compatibilidad con Flask
      },
      body: jsonEncode({
        "email": email.trim(),
        "codigo": codigo.trim(),
        "password": nuevaPassword.trim(),
      }),
    );

    debugPrint('🔍 Respuesta de Flask: ${response.body}');
    return response.statusCode == 200;
  } catch (e) {
    debugPrint('❌ Error al cambiar contraseña: $e');
    return false;
  }
}

  // 🔓 Cerrar sesión
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userEmail');
  }

  // ✅ Verificar si el usuario está logueado
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail') != null;
  }

  // 👤 Obtener datos del usuario actual desde MySQL
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('userEmail');
      if (email == null) return null;

      final response = await http.get(Uri.parse('$baseUrl/usuario/$email'));

      debugPrint('🔍 Respuesta de Flask: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error en getCurrentUser: $e');
      return null;
    }
  }
}