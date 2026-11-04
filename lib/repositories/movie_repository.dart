
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:southsea_cinema/models/movie.dart';

class MovieRepository {
  List<Movie>? _cachedMovies;

  List<Movie> getMovies() {
    final List<Movie>? cachedMovies = _cachedMovies;

    if (cachedMovies != null) {
      return cachedMovies;
    }

    // Keep original data for earlier synchronous tests.
    return const <Movie>[
      Movie(
        id: 'interstellar',
        title: 'Interstellar',
        synopsis:
            'A team of explorers travels through space searching for a new home for humanity.',
        ageRating: '12A',
        runtime: '2h 49m',
        screeningTime: '19:30',
        ticketPrice: 10.50,
        posterImagePath: 'assets/images/interstellar.jpg',
      ),
      Movie(
        id: 'inception',
        title: 'Inception',
        synopsis:
            'A skilled thief enters people\'s dreams to steal information and is given one final mission.',
        ageRating: '12A',
        runtime: '2h 28m',
        screeningTime: '21:00',
        ticketPrice: 9.50,
        posterImagePath: 'assets/images/inception.jpg',
      ),
    ];
  }

  Movie? getMovieById(String id) {
    for (final Movie movie in getMovies()) {
      if (movie.id == id) {
        return movie;
      }
    }

    return null;
  }

  Future<List<Movie>> loadMoviesFromAsset({
    String assetPath = 'assets/data/movies.json',
  }) async {
    final String jsonString =
        await rootBundle.loadString(assetPath);

    final dynamic decodedData = jsonDecode(jsonString);

    final List<dynamic> jsonList =
        decodedData as List<dynamic>;

    final List<Movie> loadedMovies = <Movie>[];

    for (final dynamic item in jsonList) {
      final Map<String, dynamic> movieMap =
          item as Map<String, dynamic>;

      final Movie movie = Movie.fromJson(movieMap);

      loadedMovies.add(movie);
    }

    _cachedMovies = loadedMovies;

    return loadedMovies;
  }
}
