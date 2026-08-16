import 'package:flutter/material.dart';

import '../home/model/menu_model.dart';
import 'repository.dart';

class CartController extends ChangeNotifier {
  final CartRepository _cartRepository = CartRepository();

  String orderType = 'Dine-In';

  List<Menu> cartItems = [];

  CartController() {
    loadCart();
  }
  // LOAD CART
  Future<void> loadCart() async {
    print('LOAD CART STARTED');

    final items = await _cartRepository.getCartItems();

    print('CART FROM DATABASE: $items');

    cartItems = items.map((item) {
      return Menu(
        id: item['menu_id'],
        menuId: item['menu_id']?.toString(),
        name: item['name'],

        // DB mein teeno prices saved hain
        price: item['price']?.toString(),
        takeAwayPrice: item['takeaway_price']?.toString(),
        deliveryPrice: item['delivery_price']?.toString(),

        image: null,
        imageUrl: null,

        description: null,
        ingridient: null,

        isDeal: false,

        menuVariations: [],
        choiceGroup: [],
        dealMenuDetails: [],

        quantity: item['quantity'],

        // IMPORTANT:
        // Database mein menu variation NULL hai.
        menuVariation: null,
      );
    }).toList();

    notifyListeners();
  }


  // ADD TO CART


  Future<void> addToCart(
      Menu food,
      int quantity,
      ) async {
    final index = cartItems.indexWhere(
          (item) => item.id == food.id,
    );


    // ITEM ALREADY IN CART


    if (index != -1) {
      final oldItem = cartItems[index];

      final newQuantity =
          (oldItem.quantity ?? 1) + quantity;

      cartItems[index] = oldItem.copyWith(
        quantity: newQuantity,
      );

      notifyListeners();

      await _cartRepository.updateQuantity(
        food.id!,
        newQuantity,
      );

      return;
    }
    // NEW ITEM

    final selectedPrice = getSelectedPrice(food);

    final newItem = food.copyWith(
      quantity: quantity,
      price: food.price,
      takeAwayPrice: food.takeAwayPrice,
      deliveryPrice: food.deliveryPrice,
    );

    // UI immediately update
    cartItems.add(newItem);

    notifyListeners();
    // SAVE TO DATABASE
    await _cartRepository.addToCart({
      'menu_id': food.id,
      'name': food.name,

      // Teeno prices DB mein save honge
      'price': double.tryParse(
        food.price ?? '0',
      ) ?? 0,

      'takeaway_price': double.tryParse(
        food.takeAwayPrice ?? '0',
      ) ?? 0,

      'delivery_price': double.tryParse(
        food.deliveryPrice ?? '0',
      ) ?? 0,

      'quantity': quantity,

      // Supervisor ke according NULL
      'menu_variation': null,
    });
  }
  // INCREASE QUANTITY


  Future<void> increaseQuantity(
      Menu food,
      ) async {
    final index = cartItems.indexWhere(
          (item) => item.id == food.id,
    );

    if (index == -1) return;

    final item = cartItems[index];

    final newQuantity =
        (item.quantity ?? 1) + 1;

    cartItems[index] = item.copyWith(
      quantity: newQuantity,
    );

    notifyListeners();

    await _cartRepository.updateQuantity(
      food.id!,
      newQuantity,
    );
  }

  // DECREASE QUANTITY


  Future<void> decreaseQuantity(
      Menu food,
      ) async {
    final index = cartItems.indexWhere(
          (item) => item.id == food.id,
    );

    if (index == -1) return;

    final item = cartItems[index];

    final quantity = item.quantity ?? 1;

    if (quantity > 1) {
      final newQuantity = quantity - 1;

      cartItems[index] = item.copyWith(
        quantity: newQuantity,
      );

      await _cartRepository.updateQuantity(
        food.id!,
        newQuantity,
      );
    } else {
      await _cartRepository.deleteCartItem(
        food.id!,
      );

      cartItems.removeAt(index);
    }

    notifyListeners();
  }
  // REMOVE FROM CART


  Future<void> removeFromCart(
      Menu food,
      ) async {
    await _cartRepository.deleteCartItem(
      food.id!,
    );

    cartItems.removeWhere(
          (item) => item.id == food.id,
    );

    notifyListeners();
  }
  // CLEAR CART

  Future<void> clearCart() async {
    cartItems.clear();

    await _cartRepository.clearCart();

    notifyListeners();
  }
  // GET SELECTED PRICE


  double getSelectedPrice(
      Menu food,
      ) {
    if (orderType == 'Delivery') {
      return double.tryParse(
        food.deliveryPrice ?? '0',
      ) ?? 0;
    }

    if (orderType == 'Takeaway') {
      return double.tryParse(
        food.takeAwayPrice ?? '0',
      ) ?? 0;
    }

    // Dine-In
    return double.tryParse(
      food.price ?? '0',
    ) ?? 0;
  }

  // =========================
  // CHANGE ORDER TYPE
  // =========================

  Future<void> changeOrderType(
      String type,
      ) async {
    orderType = type;

    for (final food in cartItems) {
      final price = getSelectedPrice(food);

      final index = cartItems.indexOf(food);

      if (index == -1) continue;

      cartItems[index] = food.copyWith(
        price: price.toString(),
      );
      final items =
      await _cartRepository.getCartItems();

      final dbItem = items.firstWhere(
            (item) => item['menu_id'] == food.id,
        orElse: () => {},
      );

      if (dbItem.isEmpty) continue;

      await _cartRepository.updateCartItem(
        dbItem['id'],
        {
          'price': price,
        },
      );
    }

    notifyListeners();
  }
}