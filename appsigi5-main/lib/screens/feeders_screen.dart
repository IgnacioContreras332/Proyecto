import 'package:appsigi5/screens/feeder_detail_screen.dart';
import 'package:appsigi5/screens/esp32_connection_screen.dart';
import 'package:flutter/material.dart';
import 'package:appsigi5/data/comederos_data.dart';
import 'dart:io'; // ✅ Importar dart:io para Socket

class FeedersScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  final Socket? socket; // ✅ Recibir la instancia del Socket

  const FeedersScreen({super.key, required this.onThemeChanged, this.socket}); // ✅ Actualizar el constructor

  @override
  State<FeedersScreen> createState() => _FeedersScreenState();
}

class _FeedersScreenState extends State<FeedersScreen> {
  late Future<List<String>> feedersFuture;

  @override
  void initState() {
    super.initState();
    feedersFuture = _loadFeeders();
    print('Socket recibido en Feeders: ${widget.socket}'); // 🔍 Para depuración
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {}); // ✅ Forzar actualización cada vez que la pantalla cambia
  }

  Future<List<String>> _loadFeeders() async {
    await Future.delayed(const Duration(seconds: 1));
    return ['Comedero 1', 'Comedero 2', 'Comedero 3'];
  }

  void _navigateToDetail(int feederId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeederDetailScreen(
          feederId: feederId,
          onThemeChanged: widget.onThemeChanged,
          // socket
          // socket: widget.socket, // ✅ Pasar el socket si es necesario en DetailScreen
        ),
      ),
    );
  }

  void _navigateToESP32Connection() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ESP32ConnectionScreen(onThemeChanged: widget.onThemeChanged),
      ),
    );
  }

  void _eliminarComedero(String feederName) {
    // Por ahora, esta función estará vacía como solicitaste.
    print('Eliminar $feederName');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Eliminar $feederName (funcionalidad no implementada)')),
    );
    // En el futuro, aquí iría la lógica para eliminar el comedero.
  }

  void _togglePower(int feederId) {
    if (widget.socket != null) { // ✅ Verificar si el socket está conectado
      print('Gestionando energía del Comedero $feederId');
      print('Enviando "$feederId" al socket: ${widget.socket}'); // 🔍 Para depuración
      widget.socket!.write('$feederId'); // ✅ Enviar el ID del comedero como string
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Acción de encendido para Comedero $feederId')),
      );
    } else {
      print("Socket es null. No se puede enviar el comando."); // 🔍 Para depuración
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se puede enviar el comando. ESP32 no conectado.')),
      );
    }
  }

  Widget _buildFeederCard(String feederName, int index) {
    // ✅ Obtener el nivel correcto basado en el índice
    String nivelComedero = switch (index + 1) {
      1 => ComederosData.nivelComedero1,
      2 => ComederosData.nivelComedero2,
      3 => ComederosData.nivelComedero3,
      _ => "Desconocido",
    };

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(feederName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text('Nivel: $nivelComedero', style: const TextStyle(color: Colors.deepPurpleAccent)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () => _eliminarComedero(feederName),
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                ),
                IconButton(
                  onPressed: () => _togglePower(index + 1), // ✅ Pasar el ID del comedero
                  icon: const Icon(Icons.power_settings_new, color: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Comederos'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              widget.onThemeChanged(
                isDarkMode ? ThemeMode.light : ThemeMode.dark,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<String>>(
              future: feedersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error al cargar los comederos: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No tienes comederos', style: TextStyle(fontSize: 18, color: Colors.deepPurpleAccent)),
                  );
                } else {
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.95, // Ajusté un poco la relación de aspecto
                    ),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return _buildFeederCard(snapshot.data![index], index);
                    },
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Agregar Comedero', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: () {}, // Puedes implementar la lógica aquí
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.wifi, color: Colors.white),
              label: const Text('Configurar ESP32', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: _navigateToESP32Connection,
            ),
          ),
        ],
      ),
    );
  }
}