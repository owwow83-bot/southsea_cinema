import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';

const testMovie = Movie(
  id: 'interstellar',
  title: 'Interstellar',
  synopsis: 'Space exploration.',
  ageRating: '12A',
  runtime: '2h 49m',
  screeningTime: '19:30',
  ticketPrice: 10.50,
  posterImagePath: 'assets/images/interstellar.jpg',
);

void main() {
  final basket = BasketRepository.instance;

  setUp(() {
    basket.clear();
  });

  test('basket starts empty', () {
    expect(basket.items, isEmpty);
    expect(basket.totalTickets, 0);
    expect(basket.total, 0.0);
  });

  test('adding tickets updates quantity and total', () {
    basket.addTickets(testMovie, 2);

    expect(basket.items.length, 1);
    expect(basket.items.first.quantity, 2);
    expect(basket.totalTickets, 2);
    expect(basket.total, 21.0);
  });

  test('adding the same movie combines quantities', () {
    basket.addTickets(testMovie, 2);
    basket.addTickets(testMovie, 1);

    expect(basket.items.length, 1);
    expect(basket.items.first.quantity, 3);
    expect(basket.total, 31.50);
  });

  test('removing tickets reduces quantity', () {
    basket.addTickets(testMovie, 3);
    basket.removeTickets('interstellar', 1);

    expect(basket.totalTickets, 2);
    expect(basket.total, 21.0);
  });

  test('removing a movie deletes the basket line', () {
    basket.addTickets(testMovie, 2);
    basket.removeMovie('interstellar');

    expect(basket.items, isEmpty);
  });

  test('clearing basket removes everything', () {
    basket.addTickets(testMovie, 5);
    basket.clear();

    expect(basket.items, isEmpty);
    expect(basket.total, 0.0);
  });
}