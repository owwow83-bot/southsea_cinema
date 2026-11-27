import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';
import 'package:southsea_cinema/widgets/nav_drawer.dart';
import 'package:southsea_cinema/widgets/primary_button.dart';

class BasketView extends StatefulWidget {
  const BasketView({super.key});

  @override
  State<BasketView> createState() => _BasketViewState();
}

class _BasketViewState extends State<BasketView> {
  String _confirmationMessage = '';

  @override
  Widget build(BuildContext context) {
    final basket = BasketRepository.instance;
    final items = basket.items;

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
            if (items.isEmpty) ...[
              Text(
                _confirmationMessage.isEmpty
                    ? 'Your basket is empty'
                    : _confirmationMessage,
                style: const TextStyle(fontSize: 18),
              ),
            ] else ...[
              const Text(
                'Your basket',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              for (final item in items)
                Card(
                  color: cinemaSurface,
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
                              const SizedBox(height: 8),
                              Text(
                                '${item.movie.formattedPrice} per ticket',
                              ),
                              Text(
                                '£${item.lineTotal.toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                        ),

                        // Remove one ticket.
                        IconButton(
                          tooltip: 'Remove one ${item.movie.title} ticket',
                          icon: const Icon(
                            Icons.remove_circle_outline,
                          ),
                          onPressed: () {
                            setState(() {
                              basket.removeTickets(item.movie.id, 1);
                            });
                          },
                        ),

                        // Remove the entire movie selection.
                        IconButton(
                          tooltip: 'Remove ${item.movie.title}',
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                          ),
                          onPressed: () {
                            setState(() {
                              basket.removeMovie(item.movie.id);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Checkout',
                onPressed: () {
                  setState(() {
                    basket.clear();
                    _confirmationMessage =
                        'Booking confirmed. Your basket is now empty.';
                  });
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  setState(() {
                    basket.clear();
                    _confirmationMessage = '';
                  });
                },
                child: const Text('Clear basket'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
