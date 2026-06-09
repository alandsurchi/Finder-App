class Validators {
  static bool isNotEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  static bool hasMinLength(String? value, int min) {
    return value != null && value.trim().length >= min;
  }

  static bool isEmail(String? value) {
    if (value == null) return false;
    final email = value.trim();
    if (email.isEmpty) return false;
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return regex.hasMatch(email);
  }

  static String? requiredField(String? value, String message) {
    return isNotEmpty(value) ? null : message;
  }
}
