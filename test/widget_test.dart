import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/main.dart';
import 'package:southsea_cinema/views/home_view.dart';
import 'package:southsea_cinema/views/movie_listing.dart';
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

    testWidgets(
      'Booking button opens selected movie listing',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const SouthseaCinemaApp(),
        );

        await tester.tap(
          find.text('Book tickets').first,
        );

        await tester.pumpAndSettle();

        expect(
          find.byType(MovieListing),
          findsOneWidget,
        );

        expect(
          find.text('Interstellar'),
          findsNWidgets(2),
        );

        expect(
          find.text('Age rating: 12A'),
          findsOneWidget,
        );

        expect(
          find.text('Runtime: 2h 49m'),
          findsOneWidget,
        );

        expect(
          find.text('Screening time: 19:30'),
          findsOneWidget,
        );

        expect(
          find.text('Ticket price: £10.50'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Add to order displays booking feedback',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const SouthseaCinemaApp(),
        );

        // Navigate to the first movie.
        await tester.tap(
          find.text('Book tickets').first,
        );

        await tester.pumpAndSettle();

        expect(
          find.byType(MovieListing),
          findsOneWidget,
        );

        expect(
          find.text('Tickets selected: 1'),
          findsOneWidget,
        );

        // Locate the button itself.
        final Finder addToOrderButton = find.widgetWithText(
          ElevatedButton,
          'Add to order',
        );

        expect(
          addToOrderButton,
          findsOneWidget,
        );

        // Scroll until the button is visible.
        await tester.ensureVisible(addToOrderButton);
        await tester.pumpAndSettle();

        // Tap it.
        await tester.tap(addToOrderButton);
        await tester.pump();

        // Check the visible booking feedback.
        expect(
          find.text(
            'Added 1 ticket for Interstellar to the order',
          ),
          findsOneWidget,
        );
      },
    );
  });
}
