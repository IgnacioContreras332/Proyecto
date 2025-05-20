import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import 'api_routes.dart';  // Asume que está en la misma carpeta o ajusta import

class AuthService {
  // 📩 Enviar código de verificación
  static Future<bool> enviarCodigo(String email) async {
    try {
      debugPrint('🔎 Enviando código de verificación: Email=$email');

      final response = await http.post(
        Uri.parse(ApiRoutes.enviarCodigo),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email.trim()}),
      );

      debugPrint('🔍 Respuesta de Django: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Error al enviar código: $e');
      return false;
    }
  }

  // 📝 Registrar usuario
  static Future<bool> registrarUsuario({
    required String email,
    required String codigo,
    required String password,
    required String name,
  }) async {
    try {
      debugPrint('🔎 Enviando registro: Email=$email');

      final response = await http.post(
        Uri.parse(ApiRoutes.registrarUsuario),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email.trim(),
          "codigo": codigo.trim(),
          "password": password.trim(),
          "name": name.trim(),
        }),
      );

      debugPrint('🔍 Respuesta de Django: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Error en registro: $e');
      return false;
    }
  }

  // 🔑 Login
  static Future<bool> login({required String email, required String password}) async {
    try {
      debugPrint('🔎 Enviando login: Email=$email');

      final response = await http.post(
        Uri.parse(ApiRoutes.login),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email.trim(),
          "password": password.trim(),
        }),
      );

      debugPrint('🔍 Respuesta de Django: ${response.body}');

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

  // 📨 Enviar código de recuperación
  static Future<bool> enviarCodigoRecuperacion(String email) async {
    try {
      debugPrint('🔎 Enviando código de recuperación: Email=$email');

      final response = await http.post(
        Uri.parse(ApiRoutes.enviarCodigoRecuperacion),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json"
        },
        body: jsonEncode({"email": email.trim()}),
      );

      debugPrint('🔍 Respuesta de Django: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Error al enviar código de recuperación: $e');
      return false;
    }
  }

  // 🔄 Cambiar contraseña
  static Future<bool> cambiarPassword({
    required String email,
    required String codigo,
    required String nuevaPassword,
  }) async {
    try {
      debugPrint('🔎 Enviando cambio de contraseña: Email=$email');

      final response = await http.post(
        Uri.parse(ApiRoutes.cambiarPassword),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json"
        },
        body: jsonEncode({
          "email": email.trim(),
          "codigo": codigo.trim(),
          "password": nuevaPassword.trim(),
        }),
      );

      debugPrint('🔍 Respuesta de Django: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Error al cambiar contraseña: $e');
      return false;
    }
  }

  // 🔓 Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userEmail');
  }

  // ✅ Verificar login
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail') != null;
  }

  // 👤 Obtener datos del usuario actual
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('userEmail');
      if (email == null) return null;

      final response = await http.get(Uri.parse(ApiRoutes.usuario(email)));

      debugPrint('🔍 Respuesta de Django: ${response.body}');
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
