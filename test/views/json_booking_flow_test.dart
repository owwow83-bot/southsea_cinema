import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/database/cinema_db.dart';
import 'package:southsea_cinema/models/booking.dart';
import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';
import 'package:southsea_cinema/repositories/movie_repository.dart';
import 'package:southsea_cinema/views/basket_view.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Movie jsonMovie;

  setUpAll(() async {
    final MovieRepository repository = MovieRepository();

    final List<Movie> movies = await repository.loadMoviesFromAsset();

    jsonMovie = movies.firstWhere(
      (movie) => movie.id == 'interstellar',
    );
  });

  setUp(() async {
    BasketRepository.instance.clear();

    sqfliteFfiInit();

    final Database db = await databaseFactoryFfiNoIsolate.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 2,
        onConfigure: CinemaDatabase.instance.configureDatabase,
        onCreate: CinemaDatabase.instance.createTables,
      ),
    );

    CinemaDatabase.instance.setDatabase(db);
  });

  tearDown(() async {
    await CinemaDatabase.instance.close();
  });

  test('JSON movie works with basket calculations', () {
    final BasketRepository basket = BasketRepository.instance;

    basket.addTickets(jsonMovie, 3);

    expect(basket.totalTickets, 3);
    expect(basket.total, 31.50);

    basket.removeTickets(jsonMovie.id, 1);

    expect(basket.totalTickets, 2);
    expect(basket.total, 21.00);
  });

  testWidgets('JSON movie checkout saves booking', (
    tester,
  ) async {
    final BasketRepository basket = BasketRepository.instance;

    basket.addTickets(jsonMovie, 2);

    await tester.pumpWidget(
      const MaterialApp(home: BasketView()),
    );

    await tester.runAsync(() async {
      await tester.tap(find.text('Checkout'));
      await tester.pumpAndSettle();
    });

    await tester.pump();

    final List<Booking>? saved = await tester.runAsync(() async {
      return CinemaDatabase.instance.getAllBookings();
    });

    expect(saved, isNotNull);
    expect(saved!.length, 1);
    expect(saved.first.summary, '2 x Interstellar');
    expect(saved.first.total, 21.00);

    expect(basket.items, isEmpty);
  });
}
