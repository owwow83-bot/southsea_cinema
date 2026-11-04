import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/main.dart';
import 'package:southsea_cinema/views/basket_view.dart';
import 'package:southsea_cinema/views/settings_view.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });
  testWidgets('Drawer opens My Basket', (tester) async {
    await tester.pumpWidget(
      const SouthseaCinemaApp(),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    await tester.tap(find.text('My Basket'));
    await tester.pumpAndSettle();

    expect(find.byType(BasketView), findsOneWidget);
    expect(find.text('My Basket'), findsWidgets);
  });

  testWidgets('Drawer opens My Settings', (tester) async {
    await tester.pumpWidget(
      const SouthseaCinemaApp(),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    await tester.tap(find.text('My Settings'));

    // Allow navigation and asynchronous loading to progress.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(SettingsView), findsOneWidget);
    expect(find.text('Customer Profile'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
