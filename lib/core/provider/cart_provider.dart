import 'package:flutter/material.dart';
import '../models/menu_model.dart';

class CartProvider extends ChangeNotifier {
  List<Menu> cartItems = [];

  void addToCart(Menu food, int quantity) {
    final index = cartItems.indexWhere(
          (item) => item.id == food.id,
    );

    if (index != -1) {
      final oldItem = cartItems[index];

      cartItems[index] = oldItem.copyWith(
        quantity: (oldItem.quantity ?? 1) + quantity,
      );
    } else {
      cartItems.add(
        food.copyWith(
          quantity: quantity,
        ),
      );
    }

    notifyListeners();
  }
  void increaseQuantity(Menu food) {
    final index = cartItems.indexWhere(
          (item) => item.id == food.id,
    );

    if (index != -1) {
      final item = cartItems[index];

      cartItems[index] = item.copyWith(
        quantity: (item.quantity ?? 1) + 1,
      );

      notifyListeners();
    }
  }

  void decreaseQuantity(Menu food) {
    final index = cartItems.indexWhere(
          (item) => item.id == food.id,
    );

    if (index != -1) {
      final item = cartItems[index];
      final quantity = item.quantity ?? 1;

      if (quantity > 1) {
        cartItems[index] = item.copyWith(
          quantity: quantity - 1,
        );
      } else {
        cartItems.removeAt(index);
      }

      notifyListeners();
    }
  }

  void removeFromCart(Menu food) {
    cartItems.removeWhere(
          (item) => item.id == food.id,
    );

    notifyListeners();
  }

  void clearCart() {
    cartItems.clear();
    notifyListeners();
  }
}