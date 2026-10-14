import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/main.dart';
import 'package:southsea_cinema/views/home_view.dart';
import 'package:southsea_cinema/widgets/movie_card.dart';

void main() {
  group('Southsea Cinema home page widget tests', () {
    testWidgets(
      'SouthseaCinemaApp displays HomeView',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const SouthseaCinemaApp(),
        );

        expect(
          find.byType(HomeView),
          findsOneWidget,
        );

        expect(
          find.text('Southsea Cinema'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Home page displays movie cards and booking buttons',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const SouthseaCinemaApp(),
        );

        expect(
          find.byType(MovieCard),
          findsNWidgets(2),
        );

        expect(
          find.text('Interstellar'),
          findsOneWidget,
        );

        expect(
          find.text('Inception'),
          findsOneWidget,
        );

        expect(
          find.text('Book tickets'),
          findsNWidgets(2),
        );
      },
    );
  });
}
