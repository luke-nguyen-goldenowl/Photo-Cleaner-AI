import 'dart:async';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:myapp/firebase_options/firebase_options_stg.dart';
import 'package:myapp/src/app.dart';
import 'package:myapp/src/locator.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:myapp/src/services/supabase/init_supabase.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  await initializeApp(
    name: "staging",
    firebaseOptions: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeSupabase();

  // Initialize Sentry with DSN from environment
  await SentryFlutter.init(
    (options) {
      options.dsn = dotenv.env['SENTRY_DSN'] ?? '';
      options.environment = 'staging';
      options.tracesSampleRate = 1.0;
      options.enableAutoSessionTracking = true;
      // Enable breadcrumbs for better debugging
      options.enableAutoPerformanceTracing = true;
    },
    appRunner: () {
      if (kIsWeb) {
        runApp(const MyApp());
      } else {
        FlutterError.onError = (errorDetails) {
          FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
        };
        // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
        PlatformDispatcher.instance.onError = (error, stack) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
          return true;
        };
        runApp(
          DevicePreview(
            enabled: !kReleaseMode,
            builder: (context) => MyApp(), // Wrap your app
          ),
        );
      }
    },
  );
}
