import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/booking_item.dart';

void main() {
  test('Each booking item calculates the correct line total', () {
    const BookingItem item = BookingItem(
      movieId: 'interstellar',
      movieTitle: 'Interstellar',
      unitPrice: 10.50,
      quantity: 3,
    );
    expect(item.lineTotal, 31.50);
  });

  test('Booking items become SQLite maps with parent ID', () {
    const BookingItem item = BookingItem(
      movieId: 'inception',
      movieTitle: 'Inception',
      unitPrice: 9.50,
      quantity: 2,
    );
    expect(item.toMapForBooking(4), {
      'booking_id': 4,
      'movie_id': 'inception',
      'movie_title': 'Inception',
      'unit_price': 9.50,
      'quantity': 2,
    });
  });

  test('SQLite row converts back to BookingItem', () {
    final BookingItem item = BookingItem.fromMap({
      'id': 12,
      'booking_id': 4,
      'movie_id': 'interstellar',
      'movie_title': 'Interstellar',
      'unit_price': 10.50,
      'quantity': 2,
    });

    expect(item.id, 12);
    expect(item.bookingId, 4);
    expect(item.movieTitle, 'Interstellar');
    expect(item.lineTotal, 21.00);
  });
}
