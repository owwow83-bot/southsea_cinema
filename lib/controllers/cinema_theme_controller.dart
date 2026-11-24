import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One small controller for the app's persistent light/dark setting.
class CinemaThemeController extends ChangeNotifier {
  CinemaThemeController({SharedPreferencesAsync? preferences})
      : _preferences = preferences ?? SharedPreferencesAsync();

  static final CinemaThemeController instance = CinemaThemeController();
  static const String preferenceKey = 'cinema_theme_mode';

  final SharedPreferencesAsync _preferences;
  ThemeMode _mode = ThemeMode.dark;
  bool _loaded = false;

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  Future<void> load() async {
    if (_loaded) return;
    final String? saved = await _preferences.getString(preferenceKey);
    _mode = saved == 'light' ? ThemeMode.light : ThemeMode.dark;
    _loaded = true;
    notifyListeners();
  }

  Future<void> setDarkMode(bool enabled) async {
    // Save first; if saving fails the on-screen selection stays unchanged.
    await _preferences.setString(preferenceKey, enabled ? 'dark' : 'light');
    _mode = enabled ? ThemeMode.dark : ThemeMode.light;
    _loaded = true;
    notifyListeners();
  }
}
