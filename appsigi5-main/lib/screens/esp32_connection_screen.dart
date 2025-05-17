import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:appsigi5/screens/feeders_screen.dart';
import 'package:appsigi5/data/comederos_data.dart';

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
  bool _dialogShown = false; // ✅ Solo muestra el mensaje una vez

  void _connectToESP32() async {
    String ipAddress = _ipController.text;
    int? port = int.tryParse(_portController.text);

    if (port != null) {
      try {
        socket = await Socket.connect(ipAddress, port);
        print('Conectado a $ipAddress:$port');
        _listenToServer(socket!);
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
        
        // ✅ Actualiza los datos y la UI
        setState(() {
          ComederosData.actualizarDatos(responseData);
        });

        print("Datos actualizados: ${ComederosData.nivelComedero1}, ${ComederosData.nivelComedero2}, ${ComederosData.nivelComedero3}");

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
          content: const Text('Servidor respondió correctamente. Datos guardados.'),
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
      appBar: AppBar(title: const Text('Conexión ESP32'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _ipController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Dirección IP', hintText: 'Ej: 192.168.137.70', border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _portController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Puerto', hintText: 'Ej: 65440', border: OutlineInputBorder(),
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