class Booking {
  final int? id;
  final int bookingNumber;
  final String summary;
  final double total;
  final String date;

  const Booking({
    this.id,
    required this.bookingNumber,
    required this.summary,
    required this.total,
    required this.date,
  });

  Map<String, Object?> toMap() {
    final Map<String, Object?> data = {
      'booking_number': bookingNumber,
      'summary': summary,
      'total': total,
      'date': date,
    };

    if (id != null) {
      data['id'] = id;
    }

    return data;
  }

  factory Booking.fromMap(Map<String, Object?> map) {
    final num totalNumber = map['total'] as num;

    return Booking(
      id: map['id'] as int?,
      bookingNumber: map['booking_number'] as int,
      summary: map['summary'] as String,
      total: totalNumber.toDouble(),
      date: map['date'] as String,
    );
  }
}
