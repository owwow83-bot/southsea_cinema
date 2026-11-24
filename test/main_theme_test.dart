import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:southsea_cinema/controllers/cinema_theme_controller.dart';
import 'package:southsea_cinema/main.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  testWidgets('MaterialApp follows the selected theme', (tester) async {
    final controller = CinemaThemeController();
    await tester.runAsync(() => controller.load());

    await tester.pumpWidget(
      SouthseaCinemaApp(themeController: controller),
    );
    await tester.pump();

    MaterialApp app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);

    await tester.runAsync(() => controller.setDarkMode(false));
    await tester.pump();

    app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.light);

    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  });
}
