import 'package:flutter/foundation.dart';
import '../config/env.dart';

class AppLogger {
  static void d(String message) {
    if (Env.enableVerboseLogs) {
      debugPrint('[DEBUG] $message');
    }
  }

  static void i(String message) => debugPrint('[INFO] $message');

  static void w(String message) => debugPrint('[WARN] $message');

  static void e(String message, [Object? error, StackTrace? stackTrace]) {
    debugPrint('[ERROR] $message');
    if (error != null) {
      debugPrint('  error: $error');
    }
    if (stackTrace != null && Env.enableVerboseLogs) {
      debugPrint(stackTrace.toString());
    }
  }
}
