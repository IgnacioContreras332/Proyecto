import 'package:flutter/material.dart';
import 'package:appsigi5/services/auth_service.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _codigoController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;
  bool _codigoEnviado = false;

  Future<void> _enviarCodigo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await AuthService.enviarCodigo(_emailController.text.trim());

    if (mounted) {
      setState(() {
        _isLoading = false;
        _codigoEnviado = success;
        _errorMessage = success ? null : 'Error al enviar código de verificación';
      });
    }
  }

  Future<void> _register() async {
    if (!_codigoEnviado) {
      setState(() => _errorMessage = 'Primero debes enviar el código de verificación');
      return;
    }

    if (_passwordController.text.length < 6) {
      setState(() => _errorMessage = 'La contraseña debe tener al menos 6 caracteres');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Las contraseñas no coinciden');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await AuthService.registrarUsuario(
      email: _emailController.text.trim(),
      codigo: _codigoController.text.trim(),
      password: _passwordController.text.trim(), // ✅ Se eliminó la encriptación
      name: _nameController.text.trim(),
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context);
      } else {
        setState(() => _errorMessage = 'Código incorrecto o email ya registrado');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Crea tu cuenta',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Pacifico', fontSize: 28.0, fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent),
              ),
              const SizedBox(height: 30),
              TextField(controller: _nameController, decoration: const InputDecoration(hintText: 'Nombre completo', border: OutlineInputBorder())),
              const SizedBox(height: 20),
              TextField(controller: _emailController, decoration: const InputDecoration(hintText: 'Email', border: OutlineInputBorder()), keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 20),
              !_codigoEnviado
                ? ElevatedButton(
                    onPressed: _isLoading ? null : _enviarCodigo,
                    child: const Text('Enviar código'),
                  )
                : Column(children: [
                    TextField(controller: _codigoController, decoration: const InputDecoration(hintText: 'Código', border: OutlineInputBorder())),
                    const SizedBox(height: 20),
                    TextField(controller: _passwordController, decoration: const InputDecoration(hintText: 'Contraseña', border: OutlineInputBorder()), obscureText: true),
                    const SizedBox(height: 20),
                    TextField(controller: _confirmPasswordController, decoration: const InputDecoration(hintText: 'Confirmar contraseña', border: OutlineInputBorder()), obscureText: true),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      child: const Text('Registrarse'),
                    ),
                  ]),
              const SizedBox(height: 15),
              if (_errorMessage != null) 
                Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('¿Ya tienes una cuenta? Inicia sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}