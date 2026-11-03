import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';
import 'package:southsea_cinema/views/basket_view.dart';

const testMovie = Movie(
  id: 'interstellar',
  title: 'Interstellar',
  synopsis: 'Space exploration.',
  ageRating: '12A',
  runtime: '2h 49m',
  screeningTime: '19:30',
  ticketPrice: 10.50,
  posterImagePath: 'assets/images/interstellar.jpg',
);

void main() {
  setUp(() {
    BasketRepository.instance.clear();
  });

  testWidgets('Basket shows empty message', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: BasketView()),
    );

    expect(
      find.text('Your basket is empty'),
      findsOneWidget,
    );
    expect(find.text('Checkout'), findsNothing);
  });

  testWidgets('Basket displays tickets and total', (tester) async {
    BasketRepository.instance.addTickets(testMovie, 2);

    await tester.pumpWidget(
      const MaterialApp(home: BasketView()),
    );

    expect(find.text('2 x Interstellar'), findsOneWidget);
    expect(find.text('Total: £21.00'), findsOneWidget);
    expect(find.text('Checkout'), findsOneWidget);
  });

  testWidgets('Remove button empties basket', (tester) async {
    BasketRepository.instance.addTickets(testMovie, 2);

    await tester.pumpWidget(
      const MaterialApp(home: BasketView()),
    );

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pump();

    expect(
      find.text('Your basket is empty'),
      findsOneWidget,
    );
    expect(BasketRepository.instance.items, isEmpty);
  });

  testWidgets('Checkout clears basket', (tester) async {
    BasketRepository.instance.addTickets(testMovie, 1);

    await tester.pumpWidget(
      const MaterialApp(home: BasketView()),
    );

    final checkout = find.text('Checkout');

    await tester.ensureVisible(checkout);
    await tester.pumpAndSettle();
    await tester.tap(checkout);
    await tester.pump();

    expect(BasketRepository.instance.items, isEmpty);
    expect(
      find.text(
        'Booking confirmed. Your basket is now empty.',
      ),
      findsOneWidget,
    );
  });
}