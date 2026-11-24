import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/database/cinema_db.dart';
import 'package:southsea_cinema/models/booking.dart';
import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';
import 'package:southsea_cinema/views/basket_view.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const Movie testMovie = Movie(
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
  setUp(() async {
    BasketRepository.instance.clear();

    sqfliteFfiInit();

    final Database db = await databaseFactoryFfiNoIsolate.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: CinemaDatabase.instance.createTables,
      ),
    );

    CinemaDatabase.instance.setDatabase(db);
  });

  tearDown(() async {
    await CinemaDatabase.instance.close();
    BasketRepository.instance.clear();
  });

  testWidgets('Basket shows empty state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: BasketView()),
    );

    expect(
      find.text('Your basket is empty'),
      findsOneWidget,
    );

    expect(find.text('Checkout'), findsNothing);
  });

  testWidgets('Basket shows tickets and total', (tester) async {
    BasketRepository.instance.addTickets(testMovie, 2);

    await tester.pumpWidget(
      const MaterialApp(home: BasketView()),
    );

    expect(find.text('2 x Interstellar'), findsOneWidget);
    expect(find.text('Total: £21.00'), findsOneWidget);
  });

  testWidgets('Removing a movie empties the basket', (
    tester,
  ) async {
    BasketRepository.instance.addTickets(testMovie, 2);

    await tester.pumpWidget(
      const MaterialApp(home: BasketView()),
    );

    await tester.tap(
      find.byKey(const Key('remove-interstellar')),
    );

    await tester.pump();

    expect(BasketRepository.instance.items, isEmpty);

    expect(
      find.text('Your basket is empty'),
      findsOneWidget,
    );
  });

  testWidgets('Checkout saves booking and clears basket', (
    tester,
  ) async {
    BasketRepository.instance.addTickets(testMovie, 2);

    await tester.pumpWidget(
      const MaterialApp(home: BasketView()),
    );

    final Finder checkout = find.text('Checkout');

    await tester.ensureVisible(checkout);

    await tester.runAsync(() async {
      await tester.tap(checkout);
      await tester.pumpAndSettle();
    });

    await tester.pump();

    final List<Booking>? bookings = await tester.runAsync(() async {
      return CinemaDatabase.instance.getAllBookings();
    });

    expect(bookings, isNotNull);
    expect(bookings!.length, 1);
    expect(bookings.first.bookingNumber, 1001);
    expect(bookings.first.summary, '2 x Interstellar');
    expect(bookings.first.total, 21.00);

    expect(BasketRepository.instance.items, isEmpty);

    expect(
      find.text('Booking #1001 saved successfully'),
      findsOneWidget,
    );

    expect(
      find.text('Booking #1001'),
      findsOneWidget,
    );
  });

  testWidgets('Failed checkout keeps the basket', (
    tester,
  ) async {
    BasketRepository.instance.addTickets(testMovie, 2);

    // Simulate a broken database by deleting its table.
    await tester.runAsync(() async {
      final Database db = await CinemaDatabase.instance.database;

      await db.execute('DROP TABLE bookings');
    });

    await tester.pumpWidget(
      const MaterialApp(home: BasketView()),
    );

    await tester.runAsync(() async {
      await tester.tap(find.text('Checkout'));
      await tester.pumpAndSettle();
    });

    await tester.pump();

    expect(
      BasketRepository.instance.totalTickets,
      2,
    );

    expect(
      find.text('2 x Interstellar'),
      findsOneWidget,
    );

    expect(
      find.textContaining('Could not save booking'),
      findsOneWidget,
    );
  });

  testWidgets('Past bookings display newest first', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await CinemaDatabase.instance.insertBooking(
        const Booking(
          bookingNumber: 1001,
          summary: '1 x Interstellar',
          total: 10.50,
          date: '20/11/2026 10:00',
        ),
      );

      await CinemaDatabase.instance.insertBooking(
        const Booking(
          bookingNumber: 1002,
          summary: '2 x Inception',
          total: 19.00,
          date: '21/11/2026 11:00',
        ),
      );
    });

    await tester.runAsync(() async {
      await tester.pumpWidget(
        const MaterialApp(home: BasketView()),
      );
      await tester.pumpAndSettle();
    });

    await tester.pump();

    expect(
      find.text('Booking #1002'),
      findsOneWidget,
    );

    expect(
      find.text('Booking #1001'),
      findsOneWidget,
    );

    final double newerY = tester.getTopLeft(find.text('Booking #1002')).dy;

    final double olderY = tester.getTopLeft(find.text('Booking #1001')).dy;

    expect(newerY, lessThan(olderY));
  });


testWidgets(
  'Removing middle movie keeps first and last',
  (WidgetTester tester) async {
    const Movie firstMovie = Movie(
      id: 'interstellar',
      title: 'Interstellar',
      synopsis: 'Space exploration.',
      ageRating: '12A',
      runtime: '2h 49m',
      screeningTime: '19:30',
      ticketPrice: 10.50,
      posterImagePath: 'assets/images/interstellar.jpg',
    );

    const Movie middleMovie = Movie(
      id: 'inception',
      title: 'Inception',
      synopsis: 'Dream exploration.',
      ageRating: '12A',
      runtime: '2h 28m',
      screeningTime: '21:00',
      ticketPrice: 9.50,
      posterImagePath: 'assets/images/inception.jpg',
    );

    const Movie lastMovie = Movie(
      id: 'the-martian',
      title: 'The Martian',
      synopsis: 'An astronaut survives on Mars.',
      ageRating: '12A',
      runtime: '2h 24m',
      screeningTime: '20:00',
      ticketPrice: 11.00,
      posterImagePath: 'assets/images/martian.jpg',
    );

    final BasketRepository basket =
        BasketRepository.instance;

    basket.addTickets(firstMovie, 1);
    basket.addTickets(middleMovie, 2);
    basket.addTickets(lastMovie, 1);

    await tester.pumpWidget(
      const MaterialApp(
        home: BasketView(),
      ),
    );

    expect(
      find.text('1 x Interstellar'),
      findsOneWidget,
    );

    expect(
      find.text('2 x Inception'),
      findsOneWidget,
    );

    expect(
      find.text('1 x The Martian'),
      findsOneWidget,
    );

    // Select the middle movie by its unique key.
    final Finder middleDeleteButton =
        find.byKey(const Key('remove-inception'));

    await tester.ensureVisible(middleDeleteButton);
    await tester.pump();

    await tester.tap(middleDeleteButton);
    await tester.pump();

    // First and last must remain.
    expect(
      find.text('1 x Interstellar'),
      findsOneWidget,
    );

    expect(
      find.text('1 x The Martian'),
      findsOneWidget,
    );

    // Middle movie must be removed.
    expect(
      find.text('2 x Inception'),
      findsNothing,
    );

    expect(basket.items.length, 2);
    expect(basket.totalTickets, 2);
    expect(basket.total, 21.50);
  },
);

}
