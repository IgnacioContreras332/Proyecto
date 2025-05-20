class ComederosData {
  static String nivelComedero1 = "Cargando...";
  static String nivelComedero2 = "Cargando...";
  static String nivelComedero3 = "Cargando...";

  static void actualizarDatos(Map<String, dynamic> responseData) {
    nivelComedero1 = responseData['nivel_comedero1'] ?? "Sin datos";
    nivelComedero2 = responseData['nivel_comedero2'] ?? "Sin datos";
    nivelComedero3 = responseData['nivel_comedero3'] ?? "Sin datos";
  }
}