
import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/repositories/movie_repository.dart';
import 'package:southsea_cinema/widgets/basket_button.dart';
import 'package:southsea_cinema/widgets/movie_card.dart';
import 'package:southsea_cinema/widgets/nav_drawer.dart';

class HomeView extends StatefulWidget {
  final String assetPath;

  const HomeView({
    super.key,
    this.assetPath = 'assets/data/movies.json',
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<Movie> _movies = [];

  bool _loading = true;

  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    try {
      final MovieRepository repository = MovieRepository();

      final List<Movie> loadedMovies =
          await repository.loadMoviesFromAsset(
        assetPath: widget.assetPath,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _movies = loadedMovies;
        _loading = false;
        _errorMessage = '';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = 'Could not load movies: $error';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget body;

    if (_loading) {
      body = const Center(
        child: CircularProgressIndicator(),
      );
    } else if (_errorMessage.isNotEmpty) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _errorMessage,
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      body = ListView.builder(
        itemCount: _movies.length,
        itemBuilder: (BuildContext context, int index) {
          return MovieCard(
            movie: _movies[index],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(appTitle),
        actions: const [
          BasketButton(),
        ],
      ),
      drawer: const NavDrawer(),
      body: body,
    );
  }
}
