# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Supabase / Postgrest
-keep class io.supabase.** { *; }
-keep class org.postgresql.** { *; }

# TFLite
-keep class org.tensorflow.** { *; }
-keep class org.tensorflow.lite.** { *; }

# OkHttp (used by many packages)
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep class okio.** { *; }

# Gson (if used)
-keep class com.google.gson.** { *; }
-keepattributes Signature
-keepattributes *Annotation*

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Sentry
-keep class io.sentry.** { *; }
-keepattributes LineNumberTable,SourceFile
