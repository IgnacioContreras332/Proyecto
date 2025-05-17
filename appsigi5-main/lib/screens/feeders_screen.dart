import 'package:appsigi5/screens/feeder_detail_screen.dart';
import 'package:appsigi5/screens/esp32_connection_screen.dart';
import 'package:flutter/material.dart';
import 'package:appsigi5/data/comederos_data.dart';

class FeedersScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;

  const FeedersScreen({super.key, required this.onThemeChanged});

  @override
  State<FeedersScreen> createState() => _FeedersScreenState();
}

class _FeedersScreenState extends State<FeedersScreen> {
  late Future<List<String>> feedersFuture;

  @override
  // void initState() {
  void initState() {
    super.initState();
    feedersFuture = _loadFeeders();
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
      child: InkWell(
        onTap: () => _navigateToDetail(index + 1),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(feederName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text('Nivel: $nivelComedero', style: const TextStyle(color: Colors.deepPurpleAccent)),
            ],
          ),
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
                      childAspectRatio: 0.9,
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