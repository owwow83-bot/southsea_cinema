
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/booking.dart';

void main() {
  const Booking newBooking = Booking(
    bookingNumber: 1004,
    summary: '2 x Interstellar',
    total: 21.00,
    date: '20/11/2026 14:30',
  );

  test('Booking constructor sets fields correctly', () {
    expect(newBooking.id, isNull);
    expect(newBooking.bookingNumber, 1004);
    expect(newBooking.summary, '2 x Interstellar');
    expect(newBooking.total, 21.00);
    expect(newBooking.date, '20/11/2026 14:30');
  });

  test('New Booking converts to database map', () {
    expect(
      newBooking.toMap(),
      {
        'booking_number': 1004,
        'summary': '2 x Interstellar',
        'total': 21.00,
        'date': '20/11/2026 14:30',
      },
    );

    expect(newBooking.toMap().containsKey('id'), isFalse);
  });

  test('Database map converts to Booking', () {
    final Map<String, Object?> row = {
      'id': 7,
      'booking_number': 1005,
      'summary': '1 x Inception',
      'total': 9.50,
      'date': '20/11/2026 15:00',
    };

    final Booking booking = Booking.fromMap(row);

    expect(booking.id, 7);
    expect(booking.bookingNumber, 1005);
    expect(booking.summary, '1 x Inception');
    expect(booking.total, 9.50);
    expect(booking.date, '20/11/2026 15:00');
    expect(booking.toMap(), row);
  });

  test('Integer total converts into double', () {
    final Map<String, Object?> row = {
      'id': 8,
      'booking_number': 1006,
      'summary': 'Test booking',
      'total': 10,
      'date': '20/11/2026 16:00',
    };

    final Booking booking = Booking.fromMap(row);

    expect(booking.total, 10.0);
    expect(booking.total, isA<double>());
  });
}
