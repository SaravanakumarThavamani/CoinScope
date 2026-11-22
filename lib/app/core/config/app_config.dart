// /// Backend URL.
// ///  * Android emulator -> http://10.0.2.2:5000   (default)
// ///  * iOS simulator    -> http://127.0.0.1:5000
// /// Override without editing code:
// ///   flutter run --dart-define=API_BASE_URL=http://192.168.1.10:5000
// class AppConfig {
//   static const String baseUrl = String.fromEnvironment(
//     'API_BASE_URL',
//     defaultValue: 'http://10.212.98.23:5000',
//   );
//   static const Duration timeout = Duration(seconds: 15);
//   static const Duration autoRefresh = Duration(seconds: 30);
// }

/// CoinScope Backend Configuration
///
/// Production: Render
/// Local Android emulator: http://10.0.2.2:5000
/// Local iOS simulator: http://127.0.0.1:5000
class AppConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://coinscope-3udc.onrender.com',
  );

  static const Duration timeout = Duration(seconds: 30);
  static const Duration autoRefresh = Duration(seconds: 30);
}
