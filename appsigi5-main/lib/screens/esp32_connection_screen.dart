import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:appsigi5/screens/feeders_screen.dart';

class ComederosData {
  static String nivelComedero1 = "";
  static String nivelComedero2 = "";
  static String nivelComedero3 = "";

  static void actualizarDatos(Map<String, dynamic> responseData) {
    nivelComedero1 = responseData['nivel_comedero1'] ?? "Desconocido";
    nivelComedero2 = responseData['nivel_comedero2'] ?? "Desconocido";
    nivelComedero3 = responseData['nivel_comedero3'] ?? "Desconocido";
  }
}

class ESP32ConnectionScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;

  const ESP32ConnectionScreen({super.key, required this.onThemeChanged});

  @override
  State<ESP32ConnectionScreen> createState() => _ESP32ConnectionScreenState();
}

class _ESP32ConnectionScreenState extends State<ESP32ConnectionScreen> {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  Socket? socket;
  bool _dialogShown = false; // ✅ Variable para controlar el diálogo

  void _connectToESP32() async {
    String ipAddress = _ipController.text;
    int? port = int.tryParse(_portController.text);

    if (port != null) {
      try {
        socket = await Socket.connect(ipAddress, port);
        print('Conectado a $ipAddress:$port');

        _listenToServer(socket!);
        print("comedero1 = ${ComederosData.nivelComedero1}, comedero2 = ${ComederosData.nivelComedero2}, comedero3 = ${ComederosData.nivelComedero3}");

      } catch (e) {
        print('Error al conectar: $e');
      }
    } else {
      print('Puerto no válido');
    }
  }

  void _listenToServer(Socket socket) {
    socket.listen((List<int> data) {
      String jsonResponse = utf8.decode(data);
      print('Respuesta del servidor: $jsonResponse');

      try {
        Map<String, dynamic> responseData = jsonDecode(jsonResponse);
        ComederosData.actualizarDatos(responseData);
        print("Comederos actualizados: ${ComederosData.nivelComedero1}, ${ComederosData.nivelComedero2}, ${ComederosData.nivelComedero3}");

        // ✅ Solo mostrar el diálogo si aún no se ha mostrado
        if (!_dialogShown) {
          _dialogShown = true;
          _showConnectionSuccessDialog();
        }

      } catch (e) {
        print("Error al procesar JSON: $e");
      }
    });
  }

  void _showConnectionSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Conexión exitosa'),
          content: Text('Servidor respondió correctamente. Datos guardados.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FeedersScreen(onThemeChanged: widget.onThemeChanged),
                  ),
                );
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conexión ESP32'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _ipController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Dirección IP',
                hintText: 'Ej: 192.168.137.70',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _portController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Puerto',
                hintText: 'Ej: 65440',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _connectToESP32,
              child: const Text('Iniciar Conexión'),
            ),
          ],
        ),
      ),
    );
  }
}