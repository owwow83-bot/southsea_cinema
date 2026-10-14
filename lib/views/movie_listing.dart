import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/models/movie.dart';

class MovieListing extends StatefulWidget {
  final Movie movie;

  const MovieListing({
    super.key,
    required this.movie,
  });

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
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: cinemaBrand,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.movie.title,
          style: cinemaHeaderStyle,
        ),
        backgroundColor: cinemaSurface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                widget.movie.posterImagePath,
                height: 240,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),

            Text(
              widget.movie.title,
              style: const TextStyle(
                color: cinemaFontWhite,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Age rating: ${widget.movie.ageRating}',
              style: const TextStyle(
                color: cinemaFontMuted,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Runtime: ${widget.movie.runtime}',
              style: const TextStyle(
                color: cinemaFontMuted,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Screening time: ${widget.movie.screeningTime}',
              style: const TextStyle(
                color: cinemaBrand,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Ticket price: £${widget.movie.ticketPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                color: cinemaFontWhite,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              widget.movie.synopsis,
              style: const TextStyle(
                color: cinemaFontWhite,
              ),
            ),

            const SizedBox(height: 24),

            DropdownMenu<int>(
              initialSelection: _ticketQuantity,
              label: const Text('Tickets'),
              onSelected: (int? value) {
                if (value != null) {
                  setState(() {
                    _ticketQuantity = value;
                    _bookingMessage = '';
                  });
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

            const SizedBox(height: 10),

            Text(
              'Tickets selected: $_ticketQuantity',
              style: const TextStyle(
                color: cinemaFontWhite,
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: cinemaBrand,
                foregroundColor: cinemaFontWhite,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              onPressed: () {
                setState(() {
                  _bookingMessage =
                      'Added $_ticketQuantity ticket${_ticketQuantity == 1 ? '' : 's'} '
                      'for ${widget.movie.title} to the order';
                });
              },
              child: const Text('Add to order'),
            ),

            if (_bookingMessage.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                _bookingMessage,
                style: const TextStyle(
                  color: cinemaBrand,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}