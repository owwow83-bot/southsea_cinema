import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:southsea_cinema/main.dart';
import 'package:southsea_cinema/views/basket_view.dart';
import 'package:southsea_cinema/views/settings_view.dart';

void main() {
  setUp(() {
    // Use test-only preferences storage.
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  testWidgets('Drawer opens My Basket', (tester) async {
    // Build the application.
    await tester.pumpWidget(
      const SouthseaCinemaApp(),
    );

    // The AppBar is available even while movies load.
    expect(find.byIcon(Icons.menu), findsOneWidget);

    // Open the drawer.
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pump();
    await tester.pump(
      const Duration(milliseconds: 350),
    );

    // Check the drawer option exists.
    expect(
      find.text('My Basket'),
      findsOneWidget,
    );

    // Navigate to Basket.
    await tester.tap(find.text('My Basket'));
    await tester.pump();
    await tester.pump(
      const Duration(milliseconds: 350),
    );

    // Verify navigation.
    expect(
      find.byType(BasketView),
      findsOneWidget,
    );
  });

  testWidgets('Drawer opens My Settings', (tester) async {
    // Build the application.
    await tester.pumpWidget(
      const SouthseaCinemaApp(),
    );

    // Do not wait for the Home loading spinner to settle.
    expect(find.byIcon(Icons.menu), findsOneWidget);

    // Open the drawer.
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pump();
    await tester.pump(
      const Duration(milliseconds: 350),
    );

    // Check the Settings option exists.
    expect(
      find.text('My Settings'),
      findsOneWidget,
    );

    // Navigate to Settings.
    await tester.tap(find.text('My Settings'));
    await tester.pump();
    await tester.pump(
      const Duration(milliseconds: 350),
    );

    // Verify that the correct page was opened.
    expect(
      find.byType(SettingsView),
      findsOneWidget,
    );
  });
}
