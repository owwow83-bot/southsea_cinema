import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/repositories/movie_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

      final Movie? movie = repository.getMovieById('interstellar');

      expect(movie, isNotNull);
      expect(movie?.title, 'Interstellar');
      expect(movie?.ticketPrice, 10.50);
    });

    test('getMovieById returns null when id does not exist', () {
      final MovieRepository repository = MovieRepository();

      final Movie? movie = repository.getMovieById('non-existent');

      expect(movie, isNull);
    });

    test('loadMoviesFromAsset loads every JSON movie', () async {
      final MovieRepository repository = MovieRepository();

      final List<Movie> movies = await repository.loadMoviesFromAsset();

      expect(movies.length, 2);

      expect(movies[0].id, 'interstellar');
      expect(movies[0].title, 'Interstellar');
      expect(movies[0].ticketPrice, 10.50);

      expect(movies[1].id, 'inception');
      expect(movies[1].title, 'Inception');
      expect(movies[1].ticketPrice, 9.50);

      // Check that the JSON-loaded result is cached.
      expect(repository.getMovies(), same(movies));

      // Existing lookup should also work with cached movies.
      expect(
        repository.getMovieById('inception')?.title,
        'Inception',
      );
    });

    test('asset loader reports a missing JSON file', () async {
      final MovieRepository repository = MovieRepository();

      await expectLater(
        repository.loadMoviesFromAsset(
          assetPath: 'assets/data/missing_movies.json',
        ),
        throwsA(isA<FlutterError>()),
      );
    });
  });
}
