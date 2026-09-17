import 'dart:convert';

import 'package:flutter/material.dart';

import '../../core/constant/app_constants.dart';
import '../../core/db/shared_pref.dart';
import '../../core/db/sqflite/controller.dart';
import '../../core/db/sqflite/model.dart';
import '../../core/utils/order_type_price.dart';
import '../home/model/menu_model.dart' hide MenuVariation;
import 'model/guest_user_response.dart' show GuestData;
import 'order_repository.dart';

class CartController extends ChangeNotifier {
  final DbController _dbController;
  final OrderRepository _orderRepository = OrderRepository();
  final SharedPrefService _prefs = SharedPrefService();
  String orderType = 'Takeaway';


  List<OrderDetails> cartItems = [];
  bool isLoading = false;
  bool isGuestCheckout = false;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  bool nameError = false;
  bool emailError = false;
  bool phoneError = false;
  bool isGuestSigningUp = false;
  GuestData? guestUserData;
  //  CHECKOUT SCREEN STATE
  bool isPlacingOrder = false;
  bool useWallet = false;
  bool isActuallyGuest = false;
  String checkoutCustomerId = '';


  void setPlacingOrder(bool value) {
    isPlacingOrder = value;
    notifyListeners();
  }

  void setUseWallet(bool value) {
    useWallet = value;
    notifyListeners();
  }

  void setIsActuallyGuest(bool value) {
    isActuallyGuest = value;
    notifyListeners();
  }

  void setCheckoutCustomerId(String value) {
    checkoutCustomerId = value;
    notifyListeners();
  }
  // Login successful hone par guest flags clear karo
  void setLoggedInCheckout() {
    isGuestCheckout = false;
    guestUserData = null;
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    nameError = false;
    emailError = false;
    phoneError = false;
    notifyListeners();
  }


  bool get isGuestLocked => guestUserData != null;
  int get totalItemCount {
    return cartItems.fold(0, (sum, item) => sum + (item.quantity ?? 1));
  }

  Future<void> triggerGuestSignUpIfValid() async {
    if (!isGuestCheckout || isGuestLocked || isGuestSigningUp) return;
    if (orderType != 'Delivery') return;
    if (!isGuestDetailsValid) return;

    await guestSignUp();
  }

  // Logged-in user ka saved data fields mein daal do (editable rahenge)
  Future<void> prefillLoggedInDetails() async {
    final name = await _prefs.getName();
    final email = await _prefs.getEmail();
    final phone = await _prefs.getPhone();

    nameController.text = name ?? '';
    emailController.text = email ?? '';
    phoneController.text = phone ?? '';

    notifyListeners();
  }

  // NEW — live validation check
  bool get isGuestDetailsValid {
    final nameValid = nameController.text.trim().isNotEmpty;
    final emailValid =
    RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(emailController.text.trim());
    final phoneValid = phoneController.text.trim().length == 11 &&
        phoneController.text.trim().startsWith('03');
    return nameValid && emailValid && phoneValid;
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
            takeawayPrice: choice.takeAwayPrice,
            deliveryPrice: choice.deliveryPrice,
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
          takeawayPrice: item.menuVariation!.takeAwayPrice,
          deliveryPrice: item.menuVariation!.deliveryPrice,
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
              takeawayPrice: choice.takeAwayPrice,
              deliveryPrice: choice.deliveryPrice,
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
    final dine = food.isDeal == true
        ? double.tryParse(food.price ?? '0') ?? 0
        : _computeSelectedPrice(food, 'DineIn');
    final takeaway = food.isDeal == true
        ? double.tryParse(food.takeAwayPrice ?? food.price ?? '0') ?? 0
        : _computeSelectedPrice(food, 'Takeaway');
    final delivery = food.isDeal == true
        ? double.tryParse(food.deliveryPrice ?? food.price ?? '0') ?? 0
        : _computeSelectedPrice(food, 'Delivery');

    final newItem = _toOrderDetails(food).copyWith(
      quantity: quantity,
      price: dine.toString(),
      takeawayPrice: takeaway.toString(),
      deliveryPrice: delivery.toString(),
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
    // Order complete ya cart clear hone pe guest state reset
    guestUserData = null;
    isActuallyGuest = false;
    checkoutCustomerId = '';
    useWallet = false;

    nameController.clear();
    emailController.clear();
    phoneController.clear();
    nameError = false;
    emailError = false;
    phoneError = false;

    notifyListeners();

  }

  // GET SELECTED PRICE
  double getSelectedPrice(Menu food) => _computeSelectedPrice(food, orderType);

  double _computeSelectedPrice(Menu food, String type) {
    double total;
    List<ChoiceGroup> relevantGroups;

    if (food.menuVariation != null) {
      // Variation base price ko REPLACE karti hai, add nahi
      total = pickOrderTypePrice(
        orderType: type,
        dinePrice: food.menuVariation!.price,
        takeawayPrice: food.menuVariation!.takeAwayPrice,
        deliveryPrice: food.menuVariation!.deliveryPrice,
      );
      relevantGroups = food.menuVariation!.choiceGroups; // nested choices
    } else {
      total = pickOrderTypePrice(
        orderType: type,
        dinePrice: food.price,
        takeawayPrice: food.takeAwayPrice,
        deliveryPrice: food.deliveryPrice,
      );
      relevantGroups = food.choiceGroup; // direct choices
    }

    for (final group in relevantGroups) {
      for (final choice in group.choices) {
        total += pickOrderTypePrice(
          orderType: type,
          dinePrice: choice.price,
          takeawayPrice: choice.takeAwayPrice,
          deliveryPrice: choice.deliveryPrice,
        );
      }
    }
    return total;
  }

  double _orderPrice(OrderDetails item) {
    double basePrice;
    List<OrderDetailChoice> relevantChoices;

    if (item.menuVariation != null) {
      basePrice = pickOrderTypePrice(
        orderType: orderType,
        dinePrice: item.menuVariation!.price,
        takeawayPrice: item.menuVariation!.takeawayPrice,
        deliveryPrice: item.menuVariation!.deliveryPrice,
      );
    } else {
      basePrice = pickOrderTypePrice(
        orderType: orderType,
        dinePrice: item.price,
        takeawayPrice: item.takeawayPrice,
        deliveryPrice: item.deliveryPrice,
      );
    }

    double choicesPrice = 0;
    for (final choice in item.orderDetailChoice) {
      choicesPrice += pickOrderTypePrice(
        orderType: orderType,
        dinePrice: choice.price,
        takeawayPrice: choice.takeawayPrice,
        deliveryPrice: choice.deliveryPrice,
      );
    }
    return basePrice + choicesPrice;
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
  // ============ GUEST CHECKOUT METHODS ============

  void startGuestCheckout() {
    isGuestCheckout = true;
    guestUserData = null;
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    nameError = false;
    emailError = false;
    phoneError = false;

    notifyListeners();
  }

  bool validateGuestDetails() {
    nameError = nameController.text.trim().isEmpty;

    emailError = emailController.text.trim().isEmpty ||
        !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(emailController.text.trim());

    phoneError = phoneController.text.trim().length != 11 ||
        !phoneController.text.trim().startsWith('03');

    notifyListeners();

    return !nameError && !emailError && !phoneError;
  }

  void onGuestNameChanged(String value) {
    if (nameError && value.trim().isNotEmpty) {
      nameError = false;
    }
    notifyListeners();
    triggerGuestSignUpIfValid(); // NEW
  }

  void onGuestEmailChanged(String value) {
    if (emailError &&
        value.isNotEmpty &&
        RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      emailError = false;
    }
    notifyListeners();
    triggerGuestSignUpIfValid(); // NEW
  }

  void onGuestPhoneChanged(String value) {
    if (phoneError && value.length == 11 && value.startsWith('03')) {
      phoneError = false;
    }
    notifyListeners();
    triggerGuestSignUpIfValid(); // NEW
  }

  Future<bool> guestSignUp() async {
    isGuestSigningUp = true;
    notifyListeners();

    try {
      final response = await _orderRepository.guestSignUp(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        restaurantId: AppConstants.restaurantId,
      );

      if (response == null || response.success != true) {
        return false;
      }
      if (response.data?.token != null) {
        await _prefs.saveToken(response.data!.token!);
        if (response.data?.customerId != null) {
          await _prefs.saveCustomerIdOnly(response.data!.customerId!);
          await _prefs.saveIsGuest(true);
        }
        guestUserData = response.data;
        notifyListeners();
        return true;
      }
      final existingToken = await _prefs.getToken();

      if (existingToken != null && existingToken.isNotEmpty) {
        guestUserData = GuestData(
          id: null,
          customerId: null,
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          cellNum: phoneController.text.trim(),
          token: existingToken,
          restaurantName: null,
          isGuest: 1,
        );
        await _prefs.saveIsGuest(true);
        notifyListeners();
        return true;
      }
      return false;
    } finally {
      isGuestSigningUp = false;
      notifyListeners();
    }
  }
  void resetGuestUser() {
    guestUserData = null;
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    nameError = false;
    emailError = false;
    phoneError = false;
    notifyListeners();
  }


  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
