-dontwarn javax.annotation.Nullable
-dontwarn org.conscrypt.Conscrypt
-dontwarn org.conscrypt.OpenSSLProvider

# Preserve native methods - prevents JNI_OnLoad UnsatisfiedLinkError
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep JNI callback methods
-keepclassmembers class * {
    void log(int, byte[]);
    void statistics(int, float, float, long, int, double, double);
}

# flutter_lame / dart_lame native bindings
-keep class com.ryanheise.** { *; }
-keep class io.flutter.** { *; }

# Audio service
-keep class com.ryanheise.audioservice.** { *; }
