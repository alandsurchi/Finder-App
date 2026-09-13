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

  static const String passwordRule =
      'Use at least 8 characters with a letter and a number.';

  /// Mirrors the server rule: 8 to 128 characters, at least one letter and one digit.
  static bool isStrongPassword(String? value) {
    if (value == null) return false;
    if (value.length < 8 || value.length > 128) return false;
    return RegExp(r'[A-Za-z]').hasMatch(value) && RegExp(r'\d').hasMatch(value);
  }

  static String? requiredField(String? value, String message) {
    return isNotEmpty(value) ? null : message;
  }
}
