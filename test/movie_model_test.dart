import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/movie.dart';

void main() {
  group('Movie model tests', () {
    test('Movie constructor assigns all properties', () {
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

    test('formattedPrice displays whole price correctly', () {
      const Movie movie = Movie(
        id: 'test1',
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

    test('formattedPrice displays decimal price correctly', () {
      const Movie movie = Movie(
        id: 'test2',
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

    test('Movie.fromJson reads all fields correctly', () {
      final Map<String, dynamic> movieJson = {
        'id': 'test-movie',
        'title': 'Test Movie',
        'synopsis': 'A film used for testing.',
        'ageRating': 'PG',
        'runtime': '1h 45m',
        'screeningTime': '18:00',
        'ticketPrice': 8.75,
        'posterImagePath': 'assets/images/test.jpg',
      };

      final Movie movie = Movie.fromJson(movieJson);

      expect(movie.id, 'test-movie');
      expect(movie.title, 'Test Movie');
      expect(movie.synopsis, 'A film used for testing.');
      expect(movie.ageRating, 'PG');
      expect(movie.runtime, '1h 45m');
      expect(movie.screeningTime, '18:00');
      expect(movie.ticketPrice, 8.75);
      expect(
        movie.posterImagePath,
        'assets/images/test.jpg',
      );

      expect(movie.toJson(), equals(movieJson));
    });

    test('Movie.fromJson converts integer price to double', () {
      final Map<String, dynamic> movieJson = {
        'id': 'whole-price',
        'title': 'Whole Price Movie',
        'synopsis': 'Testing a whole-number price.',
        'ageRating': 'U',
        'runtime': '90 minutes',
        'screeningTime': '14:00',
        'ticketPrice': 10,
        'posterImagePath': 'assets/images/test.jpg',
      };

      final Movie movie = Movie.fromJson(movieJson);

      expect(movie.ticketPrice, isA<double>());
      expect(movie.ticketPrice, 10.0);
      expect(movie.formattedPrice, '£10.00');
      expect(movie.toJson()['ticketPrice'], 10.0);
    });
  });
}
