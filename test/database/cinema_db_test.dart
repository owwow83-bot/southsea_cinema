
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/database/cinema_db.dart';
import 'package:southsea_cinema/models/booking.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUp(() async {
    sqfliteFfiInit();

    final Database db =
        await databaseFactoryFfiNoIsolate.openDatabase(
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
  });

  test('Database starts with an empty bookings table', () async {
    final List<Booking> bookings =
        await CinemaDatabase.instance.getAllBookings();

    expect(bookings, isEmpty);

    expect(
      await CinemaDatabase.instance.getNextBookingNumber(),
      1001,
    );
  });

  test('insertBooking saves a booking', () async {
    const Booking booking = Booking(
      bookingNumber: 1001,
      summary: '2 x Interstellar',
      total: 21.00,
      date: '20/11/2026 15:00',
    );

    final int id =
        await CinemaDatabase.instance.insertBooking(booking);

    expect(id, greaterThan(0));

    final List<Booking> bookings =
        await CinemaDatabase.instance.getAllBookings();

    expect(bookings.length, 1);
    expect(bookings.first.id, id);
    expect(bookings.first.bookingNumber, 1001);
    expect(bookings.first.summary, '2 x Interstellar');
    expect(bookings.first.total, 21.00);
  });

  test('Next booking number increases', () async {
    expect(
      await CinemaDatabase.instance.getNextBookingNumber(),
      1001,
    );

    await CinemaDatabase.instance.insertBooking(
      const Booking(
        bookingNumber: 1005,
        summary: '1 x Inception',
        total: 9.50,
        date: '20/11/2026 16:00',
      ),
    );

    expect(
      await CinemaDatabase.instance.getNextBookingNumber(),
      1006,
    );
  });

  test('Bookings return in descending number order', () async {
    for (final int number in [1001, 1003, 1002]) {
      await CinemaDatabase.instance.insertBooking(
        Booking(
          bookingNumber: number,
          summary: 'Test booking',
          total: 10.00,
          date: '20/11/2026 17:00',
        ),
      );
    }

    final List<Booking> bookings =
        await CinemaDatabase.instance.getAllBookings();

    expect(
      bookings.map((booking) => booking.bookingNumber).toList(),
      [1003, 1002, 1001],
    );
  });
}
