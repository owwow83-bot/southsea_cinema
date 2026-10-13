import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/widgets/nav_drawer.dart';

class MovieListing extends StatefulWidget {
  const MovieListing({super.key});

  @override
  State<MovieListing> createState() => _MovieListingState();
}

class _MovieListingState extends State<MovieListing> {
  int _ticketQuantity = 1;
  String _bookingMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          appTitle,
          style: cinemaHeaderStyle,
        ),
        backgroundColor: cinemaSurface,
        iconTheme: const IconThemeData(
          color: cinemaBrand,
        ),
        elevation: 0,
      ),
      drawer: const NavDrawer(),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Interstellar',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            const Text('Runtime: 169 minutes'),
            const SizedBox(height: 4),

            const Text('Age rating: 12A'),
            const SizedBox(height: 16),

            const Text(
              'A team of explorers travels through space searching for a new home for humanity.',
            ),
            const SizedBox(height: 24),

            DropdownMenu<int>(
              initialSelection: _ticketQuantity,
              label: const Text('Tickets'),
              onSelected: (int? value) {
                if (value != null) {
                  setState(() {
                    _ticketQuantity = value;
                  });

                  print(
                    'Tickets selected: $_ticketQuantity',
                  );
                }
              },
              dropdownMenuEntries: const [
                DropdownMenuEntry(
                  value: 1,
                  label: '1',
                ),
                DropdownMenuEntry(
                  value: 2,
                  label: '2',
                ),
                DropdownMenuEntry(
                  value: 3,
                  label: '3',
                ),
                DropdownMenuEntry(
                  value: 4,
                  label: '4',
                ),
                DropdownMenuEntry(
                  value: 5,
                  label: '5',
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              'Tickets selected: $_ticketQuantity',
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  _bookingMessage =
                      'Added $_ticketQuantity tickets to the order';
                });
              },
              child: const Text('Add to order'),
            ),

            const SizedBox(height: 16),

            Text(_bookingMessage),
          ],
        ),
      ),
    );
  }
}