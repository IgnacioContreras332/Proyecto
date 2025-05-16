import 'package:flutter/material.dart';

class ESP32ConnectionScreen extends StatefulWidget {
  const ESP32ConnectionScreen({super.key});

  @override
  State<ESP32ConnectionScreen> createState() => _ESP32ConnectionScreenState();
}

class _ESP32ConnectionScreenState extends State<ESP32ConnectionScreen> {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController();

  void _connectToESP32() {
    String ipAddress = _ipController.text;
    String port = _portController.text;

    // Aquí puedes agregar la lógica para intentar la conexión con el ESP32
    // utilizando la dirección IP y el puerto ingresados.
    print('Intentando conectar a IP: $ipAddress, Puerto: $port');

    // Puedes mostrar un mensaje de carga o un diálogo de resultado aquí.
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Conexión'),
          content: Text('Intentando conectar a $ipAddress:$port'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
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
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Dirección IP',
                hintText: 'Ej: 192.168.1.100',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _portController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Puerto',
                hintText: 'Ej: 80',
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