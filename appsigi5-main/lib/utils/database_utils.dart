import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseUtils {
  static Future<void> verRutaBaseDatos() async {
    final databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, "users.db");
    print("📂 Ruta de la base de datos SQLite: $path");
  }

  static Future<void> eliminarBaseDatos() async {
    final databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, "users.db");
    await deleteDatabase(path);
    print("🗑️ Base de datos SQLite eliminada correctamente.");
  }
}