import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static const String baseUrl = 'http://192.168.1.71:5000'; // Cambia según la IP del servidor Flask

  // 📩 Enviar código de verificación al correo
  static Future<bool> enviarCodigo(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/enviar_codigo'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"destinatario_email": email}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Error al enviar código: $e');
      return false;
    }
  }

  // 📝 Registrar usuario en MySQL vía Flask (sin encriptación)
  static Future<bool> registrarUsuario({
    required String email,
    required String codigo,
    required String password,
    required String name,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/registrar_usuario'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email.trim(),
          "codigo": codigo.trim(),
          "password": password.trim(),  // ✅ Se eliminó la encriptación
          "name": name.trim(),
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Error en registro: $e');
      return false;
    }
  }

  // 🔑 Inicio de sesión con MySQL (sin encriptación)
  static Future<bool> login({required String email, required String password}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email.trim(), "password": password.trim()}),  // ✅ Se eliminó la encriptación
      );

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