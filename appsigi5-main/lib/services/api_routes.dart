class ApiRoutes {
  static const String baseUrl = 'http://192.168.1.71:8000/api';

  static const String enviarCodigo = '$baseUrl/enviar_codigo/';
  static const String registrarUsuario = '$baseUrl/registrar_usuario/';
  static const String login = '$baseUrl/login/';
  static const String enviarCodigoRecuperacion = '$baseUrl/enviar_codigo_recuperacion/';
  static const String cambiarPassword = '$baseUrl/cambiar_password/';

  static String usuario(String email) => '$baseUrl/usuario/$email/';
}
