import 'package:southsea_cinema/models/basket_item.dart';
import 'package:southsea_cinema/models/movie.dart';

class BasketRepository {
  BasketRepository._internal();

  static final BasketRepository instance =
      BasketRepository._internal();

  final List<BasketItem> _items = [];

  List<BasketItem> get items =>
      List<BasketItem>.unmodifiable(_items);

  int get totalTickets {
    return _items.fold(
      0,
      (sum, item) => sum + item.quantity,
    );
  }

  double get total {
    return _items.fold(
      0.0,
      (sum, item) => sum + item.lineTotal,
    );
  }

  void addTickets(Movie movie, int quantity) {
    if (quantity <= 0) {
      throw ArgumentError.value(quantity, 'quantity');
    }

    final index = _items.indexWhere(
      (item) => item.movie.id == movie.id,
    );

    if (index == -1) {
      _items.add(
        BasketItem(movie: movie, quantity: quantity),
      );
    } else {
      final existingItem = _items[index];

      _items[index] = BasketItem(
        movie: movie,
        quantity: existingItem.quantity + quantity,
      );
    }
  }

  void removeMovie(String movieId) {
    _items.removeWhere(
      (item) => item.movie.id == movieId,
    );
  }

  void removeTickets(String movieId, int quantity) {
    if (quantity <= 0) {
      throw ArgumentError.value(quantity, 'quantity');
    }

    final index = _items.indexWhere(
      (item) => item.movie.id == movieId,
    );

    if (index == -1) return;

    final item = _items[index];
    final remaining = item.quantity - quantity;

    if (remaining <= 0) {
      _items.removeAt(index);
    } else {
      _items[index] = BasketItem(
        movie: item.movie,
        quantity: remaining,
      );
    }
  }

  void clear() {
    _items.clear();
  }
}