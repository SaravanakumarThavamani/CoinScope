class AppConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://coinscope-3udc.onrender.com',
  );

  static const Duration timeout = Duration(seconds: 30);
  static const Duration autoRefresh = Duration(seconds: 30);
}
