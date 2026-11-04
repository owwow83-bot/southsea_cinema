import 'package:flutter/material.dart';

class BasketButton extends StatelessWidget {
  const BasketButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'My Basket',
      icon: const Icon(Icons.shopping_basket_outlined),
      onPressed: () {
        Navigator.pushNamed(context, '/basket');
      },
    );
  }
}
