class Env {
  Env._();

  static const String baseUrl =
      String.fromEnvironment('GNEWS_BASE_URL', defaultValue: '');
  static const String apiKey =
      String.fromEnvironment('GNEWS_API_KEY', defaultValue: '');

  static bool get lengkap => baseUrl.isNotEmpty && apiKey.isNotEmpty;

  /// Menyamarkan API key sebelum URL/error ditulis ke log atau layar.
  static String samarkan(String teks) {
    var hasil = teks.replaceAllMapped(
      RegExp(r'(apikey=)[^&\s\"]+', caseSensitive: false),
      (match) => '${match[1]}***',
    );

    if (apiKey.isNotEmpty) {
      hasil = hasil.replaceAll(apiKey, '***');
    }
    return hasil;
  }
}
