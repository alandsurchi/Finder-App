class Env {
  static const String name = 'dev';
  static const bool isDev = name == 'dev';
  static const bool isStaging = name == 'staging';
  static const bool isProd = name == 'prod';

  static const bool enableVerboseLogs = isDev;
}
