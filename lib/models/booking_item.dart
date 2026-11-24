/// A purchased movie line, linked to the database row of its booking.
class BookingItem {
  final int? id;
  final int? bookingId;
  final String movieId;
  final String movieTitle;
  final double unitPrice;
  final int quantity;

  const BookingItem({
    this.id,
    this.bookingId,
    required this.movieId,
    required this.movieTitle,
    required this.unitPrice,
    required this.quantity,
  });

  double get lineTotal => unitPrice * quantity;

  Map<String, Object?> toMapForBooking(int parentBookingId) {
    return {
      'booking_id': parentBookingId,
      'movie_id': movieId,
      'movie_title': movieTitle,
      'unit_price': unitPrice,
      'quantity': quantity,
    };
  }

  factory BookingItem.fromMap(Map<String, Object?> row) {
    return BookingItem(
      id: row['id'] as int?,
      bookingId: row['booking_id'] as int?,
      movieId: row['movie_id'] as String,
      movieTitle: row['movie_title'] as String,
      unitPrice: (row['unit_price'] as num).toDouble(),
      quantity: row['quantity'] as int,
    );
  }
}
