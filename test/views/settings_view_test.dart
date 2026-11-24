import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:southsea_cinema/controllers/cinema_theme_controller.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:southsea_cinema/views/settings_view.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  testWidgets(
    'Settings page displays customer profile fields',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsView(),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Customer Profile'),
        findsOneWidget,
      );

      expect(
        find.byType(TextField),
        findsNWidgets(3),
      );

      expect(
        find.byType(Switch),
        findsNWidgets(2),
      );

      expect(
        find.text('Save Settings'),
        findsOneWidget,
      );
    },
  );

  testWidgets('Dark mode control saves the light appearance',
      (WidgetTester tester) async {
    final controller = CinemaThemeController();
    await tester.runAsync(() => controller.load());

    await tester.pumpWidget(
      MaterialApp(home: SettingsView(themeController: controller)),
    );
    await tester.pumpAndSettle();

    final Finder darkMode = find.text('Dark mode');
    await tester.ensureVisible(darkMode);
    await tester.tap(darkMode);
    await tester.pump();
    await tester.runAsync(() async {
      // Drain pending in-memory SharedPreferences writes.
      await Future<void>.delayed(const Duration(milliseconds: 10));
    });
    await tester.pump();

    expect(controller.isDark, isFalse);
    expect(
      await SharedPreferencesAsync().getString(
        CinemaThemeController.preferenceKey,
      ),
      'light',
    );
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  });

  testWidgets(
    'Settings page loads previously saved profile',
    (WidgetTester tester) async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.withData(
        <String, Object>{
          prefName: 'Alex Smith',
          prefAddress: '10 Example Road',
          prefEmail: 'alex@example.com',
          prefNewsletter: true,
        },
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsView(),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Alex Smith'),
        findsOneWidget,
      );

      expect(
        find.text('10 Example Road'),
        findsOneWidget,
      );

      expect(
        find.text('alex@example.com'),
        findsOneWidget,
      );

      final Switch newsletterSwitch = tester.widget<Switch>(
        find.byType(Switch).first,
      );

      expect(newsletterSwitch.value, isTrue);
    },
  );

  testWidgets(
    'Profile saves values and loads them when reopened',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsView(),
        ),
      );

      await tester.pumpAndSettle();

      final Finder nameField = find.byType(TextField).at(0);

      final Finder addressField = find.byType(TextField).at(1);

      final Finder emailField = find.byType(TextField).at(2);

      await tester.enterText(
        nameField,
        'Jamie Example',
      );

      await tester.enterText(
        addressField,
        '25 Test Street',
      );

      await tester.ensureVisible(emailField);

      await tester.enterText(
        emailField,
        'jamie@example.com',
      );

      final Finder newsletterSwitch = find.byType(Switch).first;

      await tester.ensureVisible(newsletterSwitch);

      await tester.tap(newsletterSwitch);
      await tester.pump();

      final Finder saveButton = find.text('Save Settings');

      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();

      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(
        find.text('Settings saved for Jamie Example'),
        findsOneWidget,
      );

      // Verify actual saved storage values.
      final SharedPreferencesAsync prefs = SharedPreferencesAsync();

      expect(
        await prefs.getString(prefName),
        'Jamie Example',
      );

      expect(
        await prefs.getString(prefAddress),
        '25 Test Street',
      );

      expect(
        await prefs.getString(prefEmail),
        'jamie@example.com',
      );

      expect(
        await prefs.getBool(prefNewsletter),
        isTrue,
      );

      // Remove the settings page completely.
      await tester.pumpWidget(
        const SizedBox.shrink(),
      );

      await tester.pump();

      // Open a fresh settings page.
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsView(),
        ),
      );

      await tester.pumpAndSettle();

      // The stored values must appear again.
      expect(
        find.text('Jamie Example'),
        findsOneWidget,
      );

      expect(
        find.text('25 Test Street'),
        findsOneWidget,
      );

      expect(
        find.text('jamie@example.com'),
        findsOneWidget,
      );

      final Switch reopenedSwitch = tester.widget<Switch>(
        find.byType(Switch).first,
      );

      expect(reopenedSwitch.value, isTrue);
    },
  );
}
