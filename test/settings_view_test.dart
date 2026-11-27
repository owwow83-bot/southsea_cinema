import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
        findsOneWidget,
      );

      expect(
        find.text('Save Settings'),
        findsOneWidget,
      );
    },
  );

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
        find.byType(Switch),
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

      final Finder newsletterSwitch = find.byType(Switch);

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
        find.byType(Switch),
      );

      expect(reopenedSwitch.value, isTrue);
    },
  );
}
