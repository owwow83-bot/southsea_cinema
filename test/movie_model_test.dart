import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/movie.dart';

void main() {
  group('Movie model tests', () {
    test('creates Movie instance with given properties', () {
      const Movie movie = Movie(
        id: 'interstellar',
        title: 'Interstellar',
        synopsis:
            'A team of explorers travels through space searching for a new home for humanity.',
        ageRating: '12A',
        runtime: '2h 49m',
        screeningTime: '19:30',
        ticketPrice: 10.50,
        posterImagePath: 'assets/images/interstellar.jpg',
      );

      expect(movie.id, 'interstellar');
      expect(movie.title, 'Interstellar');
      expect(
        movie.synopsis,
        'A team of explorers travels through space searching for a new home for humanity.',
      );
      expect(movie.ageRating, '12A');
      expect(movie.runtime, '2h 49m');
      expect(movie.screeningTime, '19:30');
      expect(movie.ticketPrice, 10.50);
      expect(
        movie.posterImagePath,
        'assets/images/interstellar.jpg',
      );
    });

    test('formattedPrice displays whole-pound price with two decimal places',
        () {
      const Movie movie = Movie(
        id: 'test-whole',
        title: 'Test Movie',
        synopsis: 'Test synopsis',
        ageRating: 'PG',
        runtime: '2h',
        screeningTime: '18:00',
        ticketPrice: 10.00,
        posterImagePath: 'assets/images/interstellar.jpg',
      );

      expect(movie.formattedPrice, '£10.00');
    });

    test('formattedPrice displays price with pence to two decimal places', () {
      const Movie movie = Movie(
        id: 'test-pence',
        title: 'Test Movie',
        synopsis: 'Test synopsis',
        ageRating: 'PG',
        runtime: '2h',
        screeningTime: '18:00',
        ticketPrice: 10.50,
        posterImagePath: 'assets/images/interstellar.jpg',
      );

      expect(movie.formattedPrice, '£10.50');
    });
  });
}
