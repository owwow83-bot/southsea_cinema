import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/repositories/movie_repository.dart';

void main() {
  group('MovieRepository unit tests', () {
    test('getMovies returns two movies', () {
      final MovieRepository repository = MovieRepository();

      final List<Movie> movies = repository.getMovies();

      expect(movies.length, 2);
    });

    test('getMovies contains expected movie data', () {
      final MovieRepository repository = MovieRepository();

      final List<Movie> movies = repository.getMovies();

      final Movie interstellar = movies[0];

      expect(interstellar.id, 'interstellar');
      expect(interstellar.title, 'Interstellar');
      expect(interstellar.ticketPrice, 10.50);
      expect(interstellar.posterImagePath, isNotEmpty);

      final Movie inception = movies[1];

      expect(inception.id, 'inception');
      expect(inception.title, 'Inception');
      expect(inception.ticketPrice, 9.50);
      expect(inception.posterImagePath, isNotEmpty);
    });

    test('getMovieById returns matching movie when id exists', () {
      final MovieRepository repository = MovieRepository();

      final Movie? movie =
          repository.getMovieById('interstellar');

      expect(movie, isNotNull);
      expect(movie?.title, 'Interstellar');
      expect(movie?.ticketPrice, 10.50);
    });

    test('getMovieById returns null when id does not exist', () {
      final MovieRepository repository = MovieRepository();

      final Movie? movie =
          repository.getMovieById('non-existent');

      expect(movie, isNull);
    });
  });
}