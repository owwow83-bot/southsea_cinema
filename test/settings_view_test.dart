import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/views/settings_view.dart';

void main() {
  testWidgets('Settings page displays profile fields', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SettingsView()),
    );

    expect(find.text('Customer Profile'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(3));
    expect(find.byType(Switch), findsOneWidget);
    expect(find.text('Save Settings'), findsOneWidget);
  });

  testWidgets('Profile form shows save confirmation', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SettingsView()),
    );

    await tester.enterText(
      find.widgetWithText(TextField, 'Full name'),
      'Alex Smith',
    );

    await tester.enterText(
      find.widgetWithText(TextField, 'Address'),
      '10 Elm Road',
    );

    await tester.enterText(
      find.widgetWithText(TextField, 'Email address'),
      'alex@example.com',
    );

    final saveButton = find.text('Save Settings');

    await tester.ensureVisible(saveButton);
    await tester.pumpAndSettle();

    await tester.tap(saveButton);
    await tester.pump();

    expect(
      find.text('Settings saved for Alex Smith'),
      findsOneWidget,
    );
  });
}