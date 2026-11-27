import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';
import 'package:southsea_cinema/repositories/movie_repository.dart';
import 'package:southsea_cinema/views/basket_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Movie jsonMovie;

  // Load the JSON movie before running the widget tests.
  // This avoids awaiting asset loading inside testWidgets.
  setUpAll(() async {
    final MovieRepository repository = MovieRepository();

    final List<Movie> movies = await repository.loadMoviesFromAsset();

    expect(movies, isNotEmpty);

    jsonMovie = movies.firstWhere(
      (movie) => movie.id == 'interstellar',
    );

    expect(jsonMovie.ticketPrice, 10.50);
  });

  // Start every test with an empty basket.
  setUp(() {
    BasketRepository.instance.clear();
  });

  test('JSON movie works with basket calculations', () {
    final basket = BasketRepository.instance;

    // Add three tickets.
    basket.addTickets(jsonMovie, 3);

    expect(basket.items.length, 1);
    expect(basket.totalTickets, 3);
    expect(basket.total, 31.50);

    // Remove one ticket.
    basket.removeTickets(jsonMovie.id, 1);

    expect(basket.totalTickets, 2);
    expect(basket.total, 21.00);

    // Clear the basket.
    basket.clear();

    expect(basket.items, isEmpty);
    expect(basket.total, 0.0);
  });

  testWidgets(
    'JSON-loaded movie appears in basket and checkout clears it',
    (WidgetTester tester) async {
      final basket = BasketRepository.instance;

      // The movie was already loaded in setUpAll.
      basket.addTickets(jsonMovie, 2);

      // Display the basket.
      await tester.pumpWidget(
        const MaterialApp(
          home: BasketView(),
        ),
      );

      await tester.pump();

      // Verify initial basket contents.
      expect(
        find.text('2 x Interstellar'),
        findsOneWidget,
      );

      expect(
        find.text('Total: £21.00'),
        findsOneWidget,
      );

      // Remove one ticket.
      final Finder removeButton = find.byTooltip(
        'Remove one Interstellar ticket',
      );

      expect(removeButton, findsOneWidget);

      await tester.ensureVisible(removeButton);
      await tester.pump();

      await tester.tap(removeButton);
      await tester.pump();

      // Verify the updated quantity and total.
      expect(basket.totalTickets, 1);

      expect(
        find.text('1 x Interstellar'),
        findsOneWidget,
      );

      expect(
        find.text('Total: £10.50'),
        findsOneWidget,
      );

      // Find the checkout button.
      final Finder checkoutButton = find.text('Checkout');

      expect(checkoutButton, findsOneWidget);

      // Make sure checkout is visible before tapping.
      await tester.ensureVisible(checkoutButton);
      await tester.pump();

      // Complete checkout.
      await tester.tap(checkoutButton);
      await tester.pump();

      // Verify the basket was cleared.
      expect(basket.items, isEmpty);
      expect(basket.totalTickets, 0);
      expect(basket.total, 0.0);

      // Verify booking confirmation.
      expect(
        find.text(
          'Booking confirmed. Your basket is now empty.',
        ),
        findsOneWidget,
      );
    },
  );
}
