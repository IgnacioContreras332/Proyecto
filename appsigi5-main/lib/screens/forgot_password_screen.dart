import 'package:flutter/material.dart';
import 'package:appsigi5/services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _codigoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _codigoEnviado = false;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _enviarCodigo() async {
    setState(() => _isLoading = true);

    final success = await AuthService.enviarCodigoRecuperacion(_emailController.text.trim());

    setState(() {
      _isLoading = false;
      _codigoEnviado = success;
      _errorMessage = success ? null : 'Error al enviar código';
    });
  }

  Future<void> _cambiarPassword() async {
    if (_passwordController.text.length < 6 || _passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Las contraseñas deben coincidir y tener al menos 6 caracteres');
      return;
    }

    setState(() => _isLoading = true);

    final success = await AuthService.cambiarPassword(
      email: _emailController.text.trim(),
      codigo: _codigoController.text.trim(),
      nuevaPassword: _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (success) {
      debugPrint('✅ Contraseña cambiada con éxito');

      // ✅ Mostrar mensaje de éxito antes de redirigir al login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña actualizada correctamente')),
      );

      // ✅ Redirigir al login después de cambiar la contraseña
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacementNamed(context, '/auth');
      });
    } else {
      debugPrint('❌ Error al cambiar contraseña');
      setState(() => _errorMessage = 'Código incorrecto o error al cambiar contraseña');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar Contraseña')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: <Widget>[
              TextField(controller: _emailController, decoration: const InputDecoration(hintText: 'Email')),
              !_codigoEnviado
                  ? ElevatedButton(onPressed: _isLoading ? null : _enviarCodigo, child: const Text('Enviar código'))
                  : Column(children: [
                      TextField(controller: _codigoController, decoration: const InputDecoration(hintText: 'Código')),
                      TextField(controller: _passwordController, decoration: const InputDecoration(hintText: 'Nueva Contraseña'), obscureText: true),
                      TextField(controller: _confirmPasswordController, decoration: const InputDecoration(hintText: 'Confirmar Contraseña'), obscureText: true),
                      const SizedBox(height: 20),
                      ElevatedButton(onPressed: _isLoading ? null : _cambiarPassword, child: const Text('Cambiar Contraseña')),
                    ]),
              const SizedBox(height: 15),
              if (_errorMessage != null) 
                Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }
}