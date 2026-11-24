import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/main.dart';

void main() {
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  test('Android is supported', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    expect(isSupportedPlatform(), isTrue);
  });

  test('Other platforms are not supported', () {
    const List<TargetPlatform> unsupportedPlatforms = [
      TargetPlatform.iOS,
      TargetPlatform.macOS,
      TargetPlatform.windows,
      TargetPlatform.linux,
      TargetPlatform.fuchsia,
    ];

    for (final TargetPlatform platform in unsupportedPlatforms) {
      debugDefaultTargetPlatformOverride = platform;

      expect(isSupportedPlatform(), isFalse);
    }
  });

  testWidgets(
    'Unsupported platform shows explanation',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const UnsupportedPlatformApp(),
      );

      expect(
        find.textContaining('Android emulator'),
        findsOneWidget,
      );
    },
  );
}
