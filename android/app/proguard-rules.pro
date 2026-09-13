# Flutter and the plugins used here ship their own consumer rules.
# Keep Google Sign-In / Play Services model classes that are accessed reflectively.
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**
