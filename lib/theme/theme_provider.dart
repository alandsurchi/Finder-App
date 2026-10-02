import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemeKey = 'app_theme_mode';

/// Light or dark, remembered across restarts. Restored in main() before the
/// first frame so the app never flashes the wrong theme.
class ThemeController extends Notifier<ThemeMode> {
  final ThemeMode _initial;
  ThemeController([this._initial = ThemeMode.light]);

  @override
  ThemeMode build() => _initial;

  void toggleTheme() => setTheme(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);

  void setTheme(ThemeMode mode) {
    state = mode;
    SharedPreferences.getInstance()
        .then((p) => p.setString(_kThemeKey, mode.name))
        .catchError((_) => false);
  }

  static Future<ThemeMode> restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_kThemeKey);
      return ThemeMode.values.firstWhere((m) => m.name == saved, orElse: () => ThemeMode.light);
    } catch (_) {
      return ThemeMode.light;
    }
  }
}

final themeControllerProvider =
    NotifierProvider<ThemeController, ThemeMode>(ThemeController.new);
