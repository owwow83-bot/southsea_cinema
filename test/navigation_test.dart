
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:southsea_cinema/main.dart';
import 'package:southsea_cinema/views/basket_view.dart';
import 'package:southsea_cinema/views/settings_view.dart';

void main() {
  // Provide test-only storage before each test.
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  testWidgets('Drawer opens My Basket', (tester) async {
    await tester.pumpWidget(
      const SouthseaCinemaApp(),
    );

    // Wait for home page movies to load.
    await tester.pumpAndSettle();

    // Open navigation drawer.
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    // Navigate to the basket page.
    await tester.tap(find.text('My Basket'));
    await tester.pumpAndSettle();

    // Verify basket page opened.
    expect(
      find.byType(BasketView),
      findsOneWidget,
    );

    expect(
      find.text('My Basket'),
      findsWidgets,
    );
  });

  testWidgets('Drawer opens My Settings', (tester) async {
    await tester.pumpWidget(
      const SouthseaCinemaApp(),
    );

    // Wait for home page movies to load.
    await tester.pumpAndSettle();

    // Open navigation drawer.
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    // Navigate to settings.
    await tester.tap(find.text('My Settings'));

    // In-memory preferences now load without a platform plugin.
    await tester.pumpAndSettle();

    // Verify settings page opened.
    expect(
      find.byType(SettingsView),
      findsOneWidget,
    );

    // Verify settings finished loading.
    expect(
      find.text('Customer Profile'),
      findsOneWidget,
    );

    expect(
      find.byType(CircularProgressIndicator),
      findsNothing,
    );
  });
}
