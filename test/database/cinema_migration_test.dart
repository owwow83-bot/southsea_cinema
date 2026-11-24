import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:southsea_cinema/database/cinema_db.dart';
import 'package:southsea_cinema/models/booking.dart';
import 'package:southsea_cinema/models/booking_item.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDirectory;
  late String databasePath;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('southsea_db_test_');
    databasePath = join(tempDirectory.path, 'bookings.db');
  });

  tearDown(() async {
    await CinemaDatabase.instance.close();
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  Future<Database> openVersion2() async {
    final Database db = await CinemaDatabase.instance.openDatabaseAtPath(
      databasePath,
      factory: databaseFactoryFfiNoIsolate,
    );
    CinemaDatabase.instance.setDatabase(db);
    return db;
  }

  test('Version 1 bookings survive a version 2 upgrade', () async {
    // Make a real version-1 database on disk.
    final Database original = await databaseFactoryFfiNoIsolate.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await CinemaDatabase.instance.createTables(db, version);
          await db.insert('bookings', {
            'booking_number': 1050,
            'summary': '2 x Interstellar',
            'total': 21.00,
            'date': '20/11/2026 14:30',
          });
        },
      ),
    );
    await original.close();

    // Open the exact same file with the new version-2 implementation.
    final Database upgraded = await openVersion2();
    final List<Booking> bookings =
        await CinemaDatabase.instance.getAllBookings();

    expect(bookings.length, 1);
    expect(bookings.first.bookingNumber, 1050);
    expect(bookings.first.total, 21.00);
    expect(
      await CinemaDatabase.instance.getItemsForBooking(bookings.first.id!),
      isEmpty,
    );

    final List<Map<String, Object?>> version =
        await upgraded.rawQuery('PRAGMA user_version');
    expect(version.first['user_version'], 2);

    final List<Map<String, Object?>> tables = await upgraded.rawQuery(
      "SELECT name FROM sqlite_master "
      "WHERE type = 'table' AND name = 'booking_items'",
    );
    expect(tables.length, 1);
  });

  test('Booking and two movie items save together', () async {
    await openVersion2();

    const Booking booking = Booking(
      bookingNumber: 1100,
      summary: '2 x Interstellar, 1 x Inception',
      total: 30.50,
      date: '21/11/2026 19:30',
    );
    const List<BookingItem> items = [
      BookingItem(
        movieId: 'interstellar',
        movieTitle: 'Interstellar',
        unitPrice: 10.50,
        quantity: 2,
      ),
      BookingItem(
        movieId: 'inception',
        movieTitle: 'Inception',
        unitPrice: 9.50,
        quantity: 1,
      ),
    ];

    final int id = await CinemaDatabase.instance.saveBookingWithItems(
      booking,
      items,
    );
    final savedItems = await CinemaDatabase.instance.getItemsForBooking(id);

    expect(savedItems.length, 2);
    expect(savedItems.first.movieTitle, 'Interstellar');
    expect(savedItems.last.movieTitle, 'Inception');
    expect(
        savedItems.fold<double>(0, (sum, item) => sum + item.lineTotal), 30.50);
  });

  test('Failed item insert rolls back the entire booking', () async {
    final Database db = await openVersion2();

    const Booking booking = Booking(
      bookingNumber: 1200,
      summary: 'This booking should not survive',
      total: 21.00,
      date: '22/11/2026 10:00',
    );

    const List<BookingItem> invalidItems = [
      BookingItem(
        movieId: 'interstellar',
        movieTitle: 'Interstellar',
        unitPrice: 10.50,
        quantity: 1,
      ),
      BookingItem(
        movieId: 'inception',
        movieTitle: 'Inception',
        unitPrice: 9.50,
        quantity: 0, // Violates CHECK (quantity > 0).
      ),
    ];

    await expectLater(
      CinemaDatabase.instance.saveBookingWithItems(booking, invalidItems),
      throwsA(isA<DatabaseException>()),
    );

    final parentRows = await db.query(
      'bookings',
      where: 'booking_number = ?',
      whereArgs: [1200],
    );
    expect(parentRows, isEmpty);

    final childRows = await db.query(
      'booking_items',
      where: 'movie_id = ?',
      whereArgs: ['interstellar'],
    );
    expect(childRows, isEmpty);
  });
}
