# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.

# Keep Flutter specific classes
-keep class io.flutter.** { *; }

# Keep Firebase classes
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Keep HTTP classes
-keep class okhttp3.** { *; }
-keep class retrofit2.** { *; }

# Keep native methods
-keepclasseswithmembers class * {
    native <methods>;
}

# Keep custom model classes if any
-keep class com.mtqmn.quranicare.models.** { *; }