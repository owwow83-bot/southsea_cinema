import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:southsea_cinema/controllers/cinema_theme_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test('New installations start in dark mode', () async {
    final controller = CinemaThemeController();
    await controller.load();

    expect(controller.mode, ThemeMode.dark);
    expect(controller.isDark, isTrue);
    controller.dispose();
  });

  test('Light mode is saved and can be restored', () async {
    final first = CinemaThemeController();
    await first.setDarkMode(false);
    expect(first.mode, ThemeMode.light);

    final preferences = SharedPreferencesAsync();
    expect(
      await preferences.getString(CinemaThemeController.preferenceKey),
      'light',
    );

    final second = CinemaThemeController();
    await second.load();
    expect(second.mode, ThemeMode.light);
    expect(second.isDark, isFalse);
    first.dispose();
    second.dispose();
  });

  test('Switching back to dark notifies listeners', () async {
    final controller = CinemaThemeController();
    int changeCount = 0;
    controller.addListener(() => changeCount++);

    await controller.setDarkMode(false);
    await controller.setDarkMode(true);

    expect(changeCount, 2);
    expect(controller.mode, ThemeMode.dark);
    expect(
      await SharedPreferencesAsync().getString(
        CinemaThemeController.preferenceKey,
      ),
      'dark',
    );
    controller.dispose();
  });
}
