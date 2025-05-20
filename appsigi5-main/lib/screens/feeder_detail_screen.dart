import 'package:flutter/material.dart';
import 'package:appsigi5/data/comederos_data.dart'; // Importar los datos compartidos

class FeederDetailScreen extends StatefulWidget {
  final int feederId; // ✅ Recibe el ID del comedero
  final Function(ThemeMode) onThemeChanged;

  const FeederDetailScreen({super.key, required this.feederId, required this.onThemeChanged});

  @override
  State<FeederDetailScreen> createState() => _FeederDetailScreenState();
}

class _FeederDetailScreenState extends State<FeederDetailScreen> {
  late String nivelComedero; // Variable para almacenar el nivel del comedero específico

  @override
  void initState() {
    super.initState();
    _cargarDatosComedero();
  }

  void _cargarDatosComedero() {
    // ✅ Asigna el valor del comedero correspondiente
    switch (widget.feederId) {
      case 1:
        nivelComedero = ComederosData.nivelComedero1;
        break;
      case 2:
        nivelComedero = ComederosData.nivelComedero2;
        break;
      case 3:
        nivelComedero = ComederosData.nivelComedero3;
        break;
      default:
        nivelComedero = "Comedero desconocido";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Comedero ${widget.feederId}'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Nivel de comida:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(nivelComedero, style: const TextStyle(fontSize: 24, color: Colors.deepPurpleAccent)),
          ],
        ),
      ),
    );
  }
}