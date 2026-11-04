import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';
import 'package:southsea_cinema/repositories/movie_repository.dart';
import 'package:southsea_cinema/views/basket_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    BasketRepository.instance.clear();
  });

  test('JSON movie works with basket calculations', () async {
    final MovieRepository movieRepository = MovieRepository();

    final movies = await movieRepository.loadMoviesFromAsset();

    final movie = movies.first;

    final basket = BasketRepository.instance;

    basket.addTickets(movie, 3);

    expect(basket.items.length, 1);
    expect(basket.totalTickets, 3);
    expect(basket.total, 31.50);

    basket.removeTickets(movie.id, 1);

    expect(basket.totalTickets, 2);
    expect(basket.total, 21.00);

    basket.clear();

    expect(basket.items, isEmpty);
    expect(basket.total, 0.0);
  });

  testWidgets(
    'JSON-loaded movie appears in basket and checkout clears it',
    (WidgetTester tester) async {
      final MovieRepository repository = MovieRepository();

      final movies = await repository.loadMoviesFromAsset();

      final movie = movies.first;

      final basket = BasketRepository.instance;

      basket.addTickets(movie, 2);

      await tester.pumpWidget(
        const MaterialApp(
          home: BasketView(),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('2 x Interstellar'),
        findsOneWidget,
      );

      expect(
        find.text('Total: £21.00'),
        findsOneWidget,
      );

      // Remove one ticket.
      await tester.tap(
        find.byTooltip(
          'Remove one Interstellar ticket',
        ),
      );

      await tester.pump();

      expect(basket.totalTickets, 1);

      expect(
        find.text('1 x Interstellar'),
        findsOneWidget,
      );

      expect(
        find.text('Total: £10.50'),
        findsOneWidget,
      );

      // Complete the temporary checkout.
      final checkoutButton = find.text('Checkout');

      await tester.ensureVisible(checkoutButton);
      await tester.pumpAndSettle();

      await tester.tap(checkoutButton);
      await tester.pump();

      expect(basket.items, isEmpty);
      expect(basket.total, 0.0);

      expect(
        find.text(
          'Booking confirmed. Your basket is now empty.',
        ),
        findsOneWidget,
      );
    },
  );
}
