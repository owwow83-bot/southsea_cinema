import 'package:flutter/material.dart';

import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/database/cinema_db.dart';
import 'package:southsea_cinema/models/basket_item.dart';
import 'package:southsea_cinema/models/booking.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';
import 'package:southsea_cinema/widgets/nav_drawer.dart';
import 'package:southsea_cinema/widgets/primary_button.dart';

class BasketView extends StatefulWidget {
  const BasketView({super.key});

  @override
  State<BasketView> createState() => _BasketViewState();
}

class _BasketViewState extends State<BasketView> {
  List<Booking> _bookings = [];

  bool _loadingBookings = true;
  bool _saving = false;

  String _historyError = '';
  String _confirmationMessage = '';

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      final List<Booking> bookings =
          await CinemaDatabase.instance.getAllBookings();

      if (!mounted) return;

      setState(() {
        _bookings = bookings;
        _historyError = '';
        _loadingBookings = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _historyError = 'Could not load bookings: $error';
        _loadingBookings = false;
      });
    }
  }

  String _buildSummary(List<BasketItem> items) {
    return items
        .map(
          (item) => '${item.quantity} x ${item.movie.title}',
        )
        .join(', ');
  }

  String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');

    final String month = date.month.toString().padLeft(2, '0');

    final String hour = date.hour.toString().padLeft(2, '0');

    final String minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/${date.year} $hour:$minute';
  }

  Future<void> _checkout() async {
    final BasketRepository basket = BasketRepository.instance;

    if (_saving || basket.items.isEmpty) {
      return;
    }

    // Take a snapshot of the items before saving.
    final List<BasketItem> selectedItems = List<BasketItem>.from(basket.items);

    final String summary = _buildSummary(selectedItems);

    final double total = basket.total;

    final String date = _formatDate(DateTime.now());

    setState(() {
      _saving = true;
      _confirmationMessage = '';
    });

    try {
      final CinemaDatabase database = CinemaDatabase.instance;

      final int bookingNumber = await database.getNextBookingNumber();

      final Booking booking = Booking(
        bookingNumber: bookingNumber,
        summary: summary,
        total: total,
        date: date,
      );

      // Save successfully before clearing the basket.
      await database.insertBooking(booking);

      basket.clear();

      if (!mounted) return;

      setState(() {
        _saving = false;
        _confirmationMessage = 'Booking #$bookingNumber saved successfully';
      });

      // Reload history so the new booking appears.
      await _loadBookings();
    } catch (error) {
      // The basket remains unchanged if saving fails.
      if (!mounted) return;

      setState(() {
        _saving = false;
        _confirmationMessage = 'Could not save booking: $error';
      });
    }
  }

  Widget _buildBookingCard(Booking booking) {
    return Card(
      color: cinemaSurface,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Booking #${booking.bookingNumber}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '£${booking.total.toStringAsFixed(2)}',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(booking.summary),
            const SizedBox(height: 4),
            Text(
              booking.date,
              style: const TextStyle(
                color: cinemaFontMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingHistory() {
    if (_loadingBookings) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_historyError.isNotEmpty) {
      return Text(_historyError);
    }

    if (_bookings.isEmpty) {
      return const Text('No bookings yet');
    }

    return Column(
      children: [
        for (final Booking booking in _bookings) _buildBookingCard(booking),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final BasketRepository basket = BasketRepository.instance;

    final List<BasketItem> items = basket.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Basket'),
      ),
      drawer: const NavDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Basket',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (items.isEmpty)
              Text(
                _confirmationMessage.isEmpty
                    ? 'Your basket is empty'
                    : _confirmationMessage,
              )
            else ...[
              for (final BasketItem item in items)
                Card(
                  color: cinemaSurface,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${item.quantity} x ${item.movie.title}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${item.movie.formattedPrice} per ticket',
                              ),
                              Text(
                                '£${item.lineTotal.toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          key: Key(
                            'remove-one-${item.movie.id}',
                          ),
                          tooltip: 'Remove one ${item.movie.title} ticket',
                          icon: const Icon(
                            Icons.remove_circle_outline,
                          ),
                          onPressed: _saving
                              ? null
                              : () {
                                  setState(() {
                                    basket.removeTickets(
                                      item.movie.id,
                                      1,
                                    );
                                  });
                                },
                        ),
                        IconButton(
                          key: Key(
                            'remove-${item.movie.id}',
                          ),
                          tooltip: 'Remove ${item.movie.title}',
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                          ),
                          onPressed: _saving
                              ? null
                              : () {
                                  setState(() {
                                    basket.removeMovie(
                                      item.movie.id,
                                    );
                                  });
                                },
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Text(
                'Total tickets: ${basket.totalTickets}',
              ),
              const SizedBox(height: 8),
              Text(
                'Total: £${basket.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              PrimaryButton(
                label: _saving ? 'Saving...' : 'Checkout',
                onPressed: () {
                  if (!_saving) {
                    _checkout();
                  }
                },
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _saving
                    ? null
                    : () {
                        setState(() {
                          basket.clear();
                          _confirmationMessage = '';
                        });
                      },
                child: const Text('Clear basket'),
              ),
            ],
            if (_confirmationMessage.isNotEmpty && items.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(_confirmationMessage),
            ],
            const SizedBox(height: 28),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              'Past Bookings',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildBookingHistory(),
          ],
        ),
      ),
    );
  }
}
