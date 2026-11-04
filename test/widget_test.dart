import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/main.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';
import 'package:southsea_cinema/views/home_view.dart';
import 'package:southsea_cinema/views/movie_listing.dart';
import 'package:southsea_cinema/widgets/movie_card.dart';
import 'package:southsea_cinema/widgets/primary_button.dart';

void main() {
  setUp(() {
    rootBundle.clear();
    BasketRepository.instance.clear();
  });

  group('Southsea Cinema widget tests', () {
    testWidgets(
      'SouthseaCinemaApp displays HomeView',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const SouthseaCinemaApp(),
        );

        await tester.pumpAndSettle();

        expect(find.byType(HomeView), findsOneWidget);

        expect(
          find.text('Southsea Cinema'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Home page loads movies from JSON',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const SouthseaCinemaApp(),
        );

        await tester.pumpAndSettle();

        expect(
          find.text('Interstellar'),
          findsOneWidget,
        );

        expect(
          find.byType(MovieCard),
          findsWidgets,
        );

        expect(
          find.text('Book tickets'),
          findsWidgets,
        );

        // The second card may be below the test viewport.
        await tester.scrollUntilVisible(
          find.text('Inception'),
          150,
        );

        expect(
          find.text('Inception'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Booking button opens selected movie listing',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const SouthseaCinemaApp(),
        );

        await tester.pumpAndSettle();

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

        await tester.pumpAndSettle();

        await tester.tap(
          find.text('Book tickets').first,
        );

        await tester.pumpAndSettle();

        expect(
          find.text('Tickets selected: 1'),
          findsOneWidget,
        );

        final Finder addButton = find.widgetWithText(
          PrimaryButton,
          'Add to order',
        );

        await tester.ensureVisible(addButton);
        await tester.pumpAndSettle();

        await tester.tap(addButton);
        await tester.pump();

        expect(
          find.text(
            'Added 1 ticket for Interstellar to the order',
          ),
          findsOneWidget,
        );

        expect(
          BasketRepository.instance.totalTickets,
          1,
        );

        expect(
          BasketRepository.instance.items.first.movie.id,
          'interstellar',
        );
      },
    );

    testWidgets(
      'Home shows an error if JSON cannot be loaded',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: HomeView(
              assetPath: 'assets/data/missing_movies.json',
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.textContaining('Could not load movies'),
          findsOneWidget,
        );

        expect(
          find.byType(MovieCard),
          findsNothing,
        );
      },
    );
  });
}
