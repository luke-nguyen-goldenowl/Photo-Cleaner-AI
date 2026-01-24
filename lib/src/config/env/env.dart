import 'package:flutter_dotenv/flutter_dotenv.dart';

class ENV {
  static const bool isDev = true;

  /// Sentry DSN for error tracking
  static String get sentryDsn => dotenv.env['SENTRY_DSN'] ?? '';

  /// Supabase
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseKey => dotenv.env['SUPABASE_KEY'] ?? '';

  /// Base API URL
  static String get baseApiUrl => dotenv.env['BASE_API_URL'] ?? '';

  static String get rapidApiUrl => dotenv.env['RAPID_API_URL'] ?? '';
  static String get rapidApiKey => dotenv.env['RAPID_API_KEY'] ?? '';
  static String get rapidApiHost => dotenv.env['RAPID_API_HOST'] ?? '';

// Api for enhance image
  static String get rapidApiUrlEnhanceImage =>
      dotenv.env['RAPID_API_URL_ENHANCE_IMAGE'] ?? '';
  static String get rapidApiHostEnhanceImage =>
      dotenv.env['RAPID_API_HOST_ENHANCE_IMAGE'] ?? '';

  /// Check if Sentry is configured
  static bool get isSentryEnabled => sentryDsn.isNotEmpty;
}
