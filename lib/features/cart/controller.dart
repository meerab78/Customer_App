import 'dart:convert';

import 'package:flutter/material.dart';

import '../../core/db/sqflite/controller.dart';
import '../../core/db/sqflite/model.dart';
import '../home/model/menu_model.dart' hide MenuVariation;

class CartController extends ChangeNotifier {
  final DbController _dbController;

  String orderType = 'Takeaway';


  List<OrderDetails> cartItems = [];
  bool isLoading = false;
  int get totalItemCount {
    return cartItems.fold(0, (sum, item) => sum + (item.quantity ?? 1));
  }

  CartController({
    DbController? dbController,
  }) : _dbController = dbController ?? DbController() {
    loadCart();
  }

  String _cartKey(OrderDetails item) {
    if (item.isDeal) {
      return '${item.menuId}_deal_${jsonEncode(item.dealDetails.map((e) => e.toJson()).toList())}';
    }

    return '${item.menuId}_${item.menuVariation?.id ?? 0}_${jsonEncode(item.orderDetailChoice.map((e) => e.toJson()).toList())}';
  }

  bool _isSameCartItem(OrderDetails a, OrderDetails b) {
    // DEAL
    if (a.isDeal || b.isDeal) {
      return a.menuId == b.menuId &&
          a.isDeal == b.isDeal &&
          _cartKey(a) == _cartKey(b);
    }

    // NORMAL ITEM
    return a.menuId == b.menuId &&
        a.menuVariation?.id == b.menuVariation?.id &&
        _cartKey(a) == _cartKey(b);
  }

  OrderDetails _toOrderDetails(Menu food) {
    final isDeal = food.isDeal == true;

    return OrderDetails(
      menuId: food.id?.toString() ?? food.menuId,
      menuName: food.name,
      price: food.price,
      takeawayPrice: food.takeAwayPrice,
      deliveryPrice: food.deliveryPrice,
      quantity: food.quantity ?? 1,
      menuVariation: isDeal || food.menuVariation == null
          ? null
          : MenuVariation(
              id: food.menuVariation!.id?.toString(),
              name: food.menuVariation!.name,
              price: food.menuVariation!.price,
              note: null,
            ),
      orderDetailChoice: isDeal ? [] : _choicesFromMenu(food),
      dealDetails: isDeal ? _dealDetailsFromMenu(food) : [],
    );
  }

  List<OrderDetailChoice> _choicesFromMenu(Menu food) {
    final groups = food.menuVariation?.choiceGroups.isNotEmpty == true
        ? food.menuVariation!.choiceGroups
        : food.choiceGroup;

    final choices = <OrderDetailChoice>[];

    for (final group in groups) {
      for (final choice in group.choices) {
        choices.add(
          OrderDetailChoice(
            choiceId: choice.id,
            choiceName: choice.name,
            price: choice.price,
            choiceGroupId: group.id?.toString(),
            choiceGroupName: group.name,
          ),
        );
      }
    }
    return choices;
  }

  List<OrderDetails> _dealDetailsFromMenu(Menu food) {
    return food.dealMenuDetails.map((item) {
      return OrderDetails(
        menuId: item.id?.toString() ?? item.menuId,
        menuName: item.name,
        price: item.price,
        takeawayPrice: item.takeAwayPrice,
        deliveryPrice: item.deliveryPrice,
        quantity: item.quantity,
        menuVariation: item.menuVariation == null
            ? null
            : MenuVariation(
                id: item.menuVariation!.id?.toString(),
                name: item.menuVariation!.name,
                price: item.menuVariation!.price,
                note: null,
              ),
        orderDetailChoice: _choicesFromDealItem(item),
        dealDetails: [],
      );
    }).toList();
  }

  List<OrderDetailChoice> _choicesFromDealItem(Menu item) {
    final choices = <OrderDetailChoice>[];

    void addFromGroups(List<ChoiceGroup> groups) {
      for (final group in groups) {
        for (final choice in group.choices) {
          choices.add(
            OrderDetailChoice(
              choiceId: choice.id,
              choiceName: choice.name,
              price: choice.price,
              choiceGroupId: group.id?.toString(),
              choiceGroupName: group.name,
            ),
          );
        }
      }
    }

    addFromGroups(item.choiceGroup);
    addFromGroups(item.menuVariation?.choiceGroups ?? []);

    return choices;
  }

  // LOAD CART FROM DATABASE
  Future<void> loadCart() async {
    isLoading = true;
    notifyListeners();
    cartItems = await _dbController.getCart();

    _applyOrderTypePrices();

    isLoading = false;
    notifyListeners();
  }

  // ADD TO CART
  Future<void> addToCart(
    Menu food,
    int quantity,
  ) async {
    final selectedPrice = food.isDeal == true
        ? double.tryParse(food.price ?? '0') ?? 0
        : getSelectedPrice(food);
    final newItem = _toOrderDetails(food).copyWith(
      quantity: quantity,
      price: selectedPrice.toString(),
      takeawayPrice: selectedPrice.toString(),
      deliveryPrice: selectedPrice.toString(),
    );

    final index = cartItems.indexWhere(
      (item) => _isSameCartItem(item, newItem),
    );

    // ITEM ALREADY IN CART
    if (index != -1) {
      final oldItem = cartItems[index];
      final newQuantity = (oldItem.quantity ?? 1) + quantity;

      if (oldItem.id != null) {
        await _dbController.updateQuantity(
          oldItem.id!,
          newQuantity,
        );
      }
    } else {
      await _dbController.addToCart(newItem);
    }

    await loadCart();
  }

  OrderDetails? simpleCartItem(Menu food) {
    if (food.isDeal == true) {
      return null;
    }

    if (food.menuVariations.isNotEmpty ||
        food.choiceGroup.isNotEmpty) {
      return null;
    }

    for (final item in cartItems) {
      if (item.menuId == food.id?.toString() && !item.isDeal) {
        return item;
      }
    }

    return null;
  }

  // UPDATE EXISTING CART ITEM
  Future<void> updateCartItem(OrderDetails item) async {
    if (item.id == null) return;

    final finalPrice = _orderPrice(item);

    await _dbController.updateCart(
      item.id!,
      item.copyWith(
        price: finalPrice.toString(),
      ),
    );

    await loadCart();
  }

  // INCREASE QUANTITY
  Future<void> increaseQuantity(OrderDetails item) async {
    if (item.id == null) return;

    await _dbController.updateQuantity(
      item.id!,
      (item.quantity ?? 1) + 1,
    );

    await loadCart();
  }

  // DECREASE QUANTITY
  Future<void> decreaseQuantity(OrderDetails item) async {
    if (item.id == null) return;

    final quantity = item.quantity ?? 1;

    if (quantity > 1) {
      await _dbController.updateQuantity(
        item.id!,
        quantity - 1,
      );
    } else {
      await _dbController.deleteCart(item.id!);
    }

    await loadCart();
  }

  // REMOVE FROM CART
  Future<void> removeFromCart(OrderDetails item) async {
    if (item.id == null) return;

    await _dbController.deleteCart(item.id!);
    await loadCart();
  }

  // CLEAR CART
  Future<void> clearCart() async {
    await _dbController.clearCart();
    await loadCart();
  }

  // GET SELECTED PRICE
  double getSelectedPrice(Menu food) {
    final basePrice = double.tryParse(food.price ?? '0') ?? 0;

    double variationPrice = 0;

    if (food.menuVariation != null) {
      variationPrice =
          double.tryParse(food.menuVariation!.price ?? '0') ?? 0;
    }

    double choicesPrice = 0;

    for (final group in food.choiceGroup) {
      for (final choice in group.choices) {
        choicesPrice += double.tryParse(choice.price ?? '0') ?? 0;
      }
    }

    final finalPrice = basePrice + variationPrice + choicesPrice;

    return finalPrice;
  }

  double _orderPrice(OrderDetails item) {
    final basePrice = double.tryParse(item.price ?? '0') ?? 0;

    final variationPrice =
        double.tryParse(item.menuVariation?.price ?? '0') ?? 0;

    double choicesPrice = 0;

    for (final choice in item.orderDetailChoice) {
      choicesPrice += double.tryParse(choice.price ?? '0') ?? 0;
    }

    return basePrice + variationPrice + choicesPrice;
  }

  // CHANGE ORDER TYPE
  Future<void> changeOrderType(String type) async {
    orderType = type;
    await loadCart();
  }void _applyOrderTypePrices() {
    for (int i = 0; i < cartItems.length; i++) {
      final item = cartItems[i];

      final dineInPrice =
          double.tryParse(item.price ?? '0') ?? 0;

      final takeawayPrice =
          double.tryParse(item.takeawayPrice ?? '0') ?? 0;

      final deliveryPrice =
          double.tryParse(item.deliveryPrice ?? '0') ?? 0;

      double selectedPrice;

      if (orderType == 'Delivery') {
        selectedPrice = deliveryPrice;
      } else if (orderType == 'Takeaway') {
        selectedPrice = takeawayPrice;
      } else {
        selectedPrice = dineInPrice;
      }

      // IMPORTANT:
      // price already final hai.
      // Variation aur choices dobara add nahi karni.
      cartItems[i] = item.copyWith(
        price: selectedPrice.toString(),
      );
    }
  }

}
