import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:flutter/material.dart';

import '../home/model/menu_model.dart';
import 'repository.dart';

class CartController extends ChangeNotifier {
  final CartRepository _cartRepository = CartRepository();

  String orderType = 'Dine-In';

  List<Menu> cartItems = [];

  final Map<String, int> _cartDatabaseIds = {};

  CartController() {
    loadCart();
  }
  String _cartKey(Menu food) {
    if (food.isDeal == true) {
      return '${food.id}_deal_${_encodeDeal(food) ?? ''}';
    }
    return '${food.id}_${food.menuVariation?.id ?? 0}_${_encodeChoices(food)}';
  }

  bool _isSameCartItem(Menu a, Menu b) {
    // DEAL
    if (a.isDeal == true || b.isDeal == true) {
      return a.id == b.id &&
          a.isDeal == b.isDeal &&
          a.price == b.price &&
          _encodeDeal(a) == _encodeDeal(b);
    }
    // NORMAL ITEM
    return a.id == b.id &&
        a.menuVariation?.id == b.menuVariation?.id &&
        a.price == b.price &&
        _encodeChoices(a) == _encodeChoices(b);
  }

  String _encodeChoices(Menu food) {
    final selectedGroups =
        food.menuVariation?.choiceGroups ?? [];

    final selectedChoices = <Map<String, dynamic>>[];

    for (final group in selectedGroups) {
      for (final choice in group.choices) {
        selectedChoices.add({
          'id': choice.id,
          'name': choice.name,
          'price': choice.price,
          'choice_group_id': group.id,
          'choice_group_name': group.name,
        });
      }
    }

    return jsonEncode(selectedChoices);
  }

  String? _encodeDeal(Menu food) {
    if (food.isDeal != true || food.dealMenuDetails.isEmpty) {
      return null;
    }

    final dealItems = food.dealMenuDetails.map((item) {
      return {
        'id': item.id,
        'menu_id': item.menuId,
        'name': item.name,
        'price': item.price,
        'takeaway_price': item.takeAwayPrice,
        'delivery_price': item.deliveryPrice,
        'quantity': item.quantity,

        // Direct choice groups
        'choice_groups': item.choiceGroup.map((group) {
          return {
            'id': group.id,
            'name': group.name,
            'min_choices': group.minChoices,
            'max_choices': group.maxChoices,
            'choices': group.choices.map((choice) {
              return {
                'id': choice.id,
                'name': choice.name,
                'price': choice.price,
              };
            }).toList(),
          };
        }).toList(),

        // Selected variation
        'menu_variation': item.menuVariation == null
            ? null
            : {
          'id': item.menuVariation!.id,
          'name': item.menuVariation!.name,
          'price': item.menuVariation!.price,
          'takeaway_price':
          item.menuVariation!.takeAwayPrice,
          'delivery_price':
          item.menuVariation!.deliveryPrice,

          // Variation ke selected choices
          'choice_groups':
          item.menuVariation!.choiceGroups.map((group) {
            return {
              'id': group.id,
              'name': group.name,
              'min_choices': group.minChoices,
              'max_choices': group.maxChoices,
              'choices': group.choices.map((choice) {
                return {
                  'id': choice.id,
                  'name': choice.name,
                  'price': choice.price,
                };
              }).toList(),
            };
          }).toList(),
        },
      };
    }).toList();

    return jsonEncode(dealItems);
  }

  // LOAD CART
  Future<void> loadCart() async {
    final items = await _cartRepository.getCartItems();

    cartItems = items.map((item) {
      final dineInPrice =
          double.tryParse(item['price']?.toString() ?? '0') ?? 0;

      final takeawayPrice =
          double.tryParse(
            item['takeaway_price']?.toString() ?? '0',
          ) ??
              0;

      final deliveryPrice =
          double.tryParse(
            item['delivery_price']?.toString() ?? '0',
          ) ??
              0;

      final selectedChoices = _parseChoices(item['choices']);

      final selectedVariation = _parseMenuVariation(
        item['menu_variation'],
      );
      final dealItems = _parseDeal(item['deal_details']);
      final menu = Menu(
        id: item['menu_id'],
        menuId: item['menu_id']?.toString(),
        name: item['name'],
        price: dineInPrice.toString(),
        takeAwayPrice: takeawayPrice.toString(),
        deliveryPrice: deliveryPrice.toString(),
        image: null,
        imageUrl: null,
        description: null,
        ingridient: null,
        isDeal: dealItems.isNotEmpty,
        menuVariations: [],
        choiceGroup: selectedChoices,
        dealMenuDetails: dealItems,
        quantity: item['quantity'],
        menuVariation: selectedVariation,
      );
      final databaseId = item['id'];
      if (databaseId != null) {
        _cartDatabaseIds[_cartKey(menu)] = databaseId;
      }


      return menu;
    }).toList();

    notifyListeners();
  }

  List<ChoiceGroup> _parseChoices(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return [];
    }

    try {
      final List<dynamic> data =
      jsonDecode(value.toString());

      final Map<int, List<MenuVariation>> groupedChoices = {};
      final Map<int, String?> groupNames = {};

      for (final item in data) {
        final groupId = item['choice_group_id'];

        if (groupId == null) continue;

        // Group name save/read karo
        groupNames[groupId] =
            item['choice_group_name']?.toString();

        final choice = MenuVariation(
          id: item['id'],
          name: item['name'],
          price: item['price']?.toString(),
          takeAwayPrice: null,
          deliveryPrice: null,
          choiceGroups: [],
        );

        groupedChoices.putIfAbsent(
          groupId,
              () => [],
        );

        groupedChoices[groupId]!.add(choice);
      }

      return groupedChoices.entries.map((entry) {
        return ChoiceGroup(
          id: entry.key,
          name: groupNames[entry.key],
          minChoices: 0,
          maxChoices: 0,
          choices: entry.value,
        );
      }).toList();
    } catch (e) {
      debugPrint(
        'Error parsing choices: $e',
      );

      return [];
    }
  }

  MenuVariation? _parseMenuVariation(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return null;
    }

    try {
      final data = jsonDecode(value.toString());

      return MenuVariation(
        id: data['id'],
        name: data['name'],
        price: data['price']?.toString(),
        takeAwayPrice: null,
        deliveryPrice: null,
        choiceGroups: [],
      );
    } catch (e) {
      debugPrint(
        'Error parsing menu variation: $e',
      );

      return null;
    }
  }
  List<Menu> _parseDeal(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return [];
    }

    try {
      final List<dynamic> data =
      jsonDecode(value.toString());

      return data.map<Menu>((item) {
        // -----------------------------
        // DIRECT CHOICE GROUPS
        // -----------------------------

        final List<ChoiceGroup> directGroups = [];

        final choiceGroupsData =
        item['choice_groups'];

        if (choiceGroupsData is List) {
          for (final groupData in choiceGroupsData) {
            final List<MenuVariation> choices = [];

            final choicesData =
            groupData['choices'];

            if (choicesData is List) {
              for (final choiceData in choicesData) {
                choices.add(
                  MenuVariation(
                    id: choiceData['id'],
                    name: choiceData['name'],
                    price:
                    choiceData['price']?.toString(),
                    takeAwayPrice: null,
                    deliveryPrice: null,
                    choiceGroups: [],
                  ),
                );
              }
            }

            directGroups.add(
              ChoiceGroup(
                id: groupData['id'],
                name: groupData['name'],
                minChoices:
                groupData['min_choices'],
                maxChoices:
                groupData['max_choices'],
                choices: choices,
              ),
            );
          }
        }

        // -----------------------------
        // MENU VARIATION
        // -----------------------------

        MenuVariation? selectedVariation;

        final variationData =
        item['menu_variation'];

        if (variationData != null) {
          final List<ChoiceGroup>
          variationGroups = [];

          final variationGroupsData =
          variationData['choice_groups'];

          if (variationGroupsData is List) {
            for (final groupData
            in variationGroupsData) {
              final List<MenuVariation> choices = [];

              final choicesData =
              groupData['choices'];

              if (choicesData is List) {
                for (final choiceData
                in choicesData) {
                  choices.add(
                    MenuVariation(
                      id: choiceData['id'],
                      name: choiceData['name'],
                      price: choiceData['price']
                          ?.toString(),
                      takeAwayPrice: null,
                      deliveryPrice: null,
                      choiceGroups: [],
                    ),
                  );
                }
              }

              variationGroups.add(
                ChoiceGroup(
                  id: groupData['id'],
                  name: groupData['name'],
                  minChoices:
                  groupData['min_choices'],
                  maxChoices:
                  groupData['max_choices'],
                  choices: choices,
                ),
              );
            }
          }

          selectedVariation = MenuVariation(
            id: variationData['id'],
            name: variationData['name'],
            price:
            variationData['price']?.toString(),
            takeAwayPrice:
            variationData['takeaway_price']
                ?.toString(),
            deliveryPrice:
            variationData['delivery_price']
                ?.toString(),
            choiceGroups: variationGroups,
          );
        }

        // -----------------------------
        // FINAL DEAL ITEM
        // -----------------------------

        return Menu(
          id: item['id'],
          menuId: item['menu_id']?.toString(),
          name: item['name'],

          price: item['price']?.toString(),
          takeAwayPrice:
          item['takeaway_price']?.toString(),
          deliveryPrice:
          item['delivery_price']?.toString(),

          image: null,
          imageUrl: null,
          description: null,
          ingridient: null,

          isDeal: false,

          menuVariations: [],

          choiceGroup: directGroups,

          dealMenuDetails: [],

          quantity: item['quantity'],

          menuVariation: selectedVariation,
        );
      }).toList();
    } catch (e) {
      debugPrint(
        'Error parsing deal: $e',
      );

      return [];
    }
  }


  // ADD TO CART
  Future<void> addToCart(
      Menu food,
      int quantity,
      ) async {
    final index = cartItems.indexWhere(
          (item) => _isSameCartItem(item, food),
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
      final databaseId = _cartDatabaseIds[_cartKey(oldItem)];

      if (databaseId != null) {
        await _cartRepository.updateQuantity(
          databaseId,
          newQuantity,
        );
      }
      return;
    }
    // NEW ITEM
    final selectedPrice = food.isDeal == true
        ? double.tryParse(food.price ?? '0') ?? 0
        : getSelectedPrice(food);

    final newItem = food.copyWith(
      quantity: quantity,
      menuVariation: food.menuVariation,
      choiceGroup: food.menuVariation?.choiceGroups ?? food.choiceGroup,
    );
// SAVE TO DATABASE FIRST
    final cartData = {
      'menu_id': food.id,
      'name': food.name,
      'price': selectedPrice,
      'takeaway_price':
      double.tryParse(
        food.takeAwayPrice ?? '0',
      ) ??
          0,
      'delivery_price':
      double.tryParse(
        food.deliveryPrice ?? '0',
      ) ??
          0,
      'quantity': quantity,

      'menu_variation': food.isDeal == true
          ? null
          : food.menuVariation == null
          ? null
          : jsonEncode({
        'id': food.menuVariation!.id,
        'name': food.menuVariation!.name,
        'price': food.menuVariation!.price,
      }),
      'choices': food.isDeal == true
          ? null
          : _encodeChoices(food),
      'deal_details': _encodeDeal(food),
    };
    final databaseId =
    await _cartRepository.addToCart(cartData);
    _cartDatabaseIds[_cartKey(newItem)] = databaseId;
// NOW update UI
    debugPrint('========== BEFORE CART ADD ==========');
    debugPrint('ITEM: ${newItem.name}');
    debugPrint(
      'VARIATION: ${newItem.menuVariation?.id} - ${newItem.menuVariation?.name}',
    );
    debugPrint(
      'VARIATION PRICE: ${newItem.menuVariation?.price}',
    );
    debugPrint('PRICE: ${newItem.price}');
    debugPrint('====================================');
    cartItems.add(newItem);
    notifyListeners();
  }
  // INCREASE QUANTITY


  Future<void> increaseQuantity(Menu food) async {
    final index = cartItems.indexWhere(
          (item) => _isSameCartItem(item, food),
    );
    if (index == -1) return;
    final item = cartItems[index];
    final newQuantity = (item.quantity ?? 1) + 1;
    cartItems[index] = item.copyWith(
      quantity: newQuantity,
    );
    notifyListeners();
    final databaseId = _cartDatabaseIds[_cartKey(item)];
    if (databaseId != null) {
      await _cartRepository.updateQuantity(
        databaseId,
        newQuantity,
      );
    }
  }
  // DECREASE QUANTITY
  Future<void> decreaseQuantity(Menu food) async {
    final index = cartItems.indexWhere(
          (item) => _isSameCartItem(item, food),
    );
    if (index == -1) return;
    final item = cartItems[index];
    final quantity = item.quantity ?? 1;
    final databaseId = _cartDatabaseIds[_cartKey(item)];
    if (quantity > 1) {
      final newQuantity = quantity - 1;
      cartItems[index] = item.copyWith(
        quantity: newQuantity,
      );
      notifyListeners();
      if (databaseId != null) {
        await _cartRepository.updateQuantity(
          databaseId,
          newQuantity,
        );
      }
    } else {
      if (databaseId != null) {
        await _cartRepository.deleteCartItem(
          databaseId,
        );
      }
      _cartDatabaseIds.remove(_cartKey(item));
      cartItems.removeAt(index);

      notifyListeners();
    }
  }
  // REMOVE FROM CART


  Future<void> removeFromCart(Menu food) async {
    final index = cartItems.indexWhere(
          (item) => _isSameCartItem(item, food),
    );
    if (index == -1) return;
    final item = cartItems[index];
    final databaseId = _cartDatabaseIds[_cartKey(item)];
    if (databaseId != null) {
      await _cartRepository.deleteCartItem(
        databaseId,
      );
      _cartDatabaseIds.remove(
        _cartKey(item),
      );
    }
    cartItems.removeAt(index);
    notifyListeners();
  }
  // CLEAR CART

  Future<void> clearCart() async {
    cartItems.clear();

    await _cartRepository.clearCart();

    notifyListeners();
  }
  // GET SELECTED PRICE


  double getSelectedPrice(Menu food) {

    // Customized item ki final price
    // har order type mein currently use hogi.
    if (food.menuVariation != null &&
        food.menuVariation!.price != null &&
        food.menuVariation!.price!.isNotEmpty) {
      return double.tryParse(
        food.menuVariation!.price!,
      ) ?? 0;
    }

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

    return double.tryParse(
      food.price ?? '0',
    ) ?? 0;
  }

  // CHANGE ORDER TYPE
  Future<void> changeOrderType(String type) async {
    orderType = type;

    final dbItems = await _cartRepository.getCartItems();

    for (int i = 0; i < cartItems.length; i++) {
      final food = cartItems[i];

      final dbItem = dbItems.firstWhere(
            (item) => item['menu_id'] == food.id,
        orElse: () => {},
      );

      if (dbItem.isEmpty) {
        continue;
      }

      // ORIGINAL PRICES
      final dineInPrice =
          double.tryParse(
            dbItem['price']?.toString() ?? '0',
          ) ??
              0;

      final takeawayPrice =
          double.tryParse(
            dbItem['takeaway_price']?.toString() ?? '0',
          ) ??
              0;

      final deliveryPrice =
          double.tryParse(
            dbItem['delivery_price']?.toString() ?? '0',
          ) ??
              0;

      double selectedPrice;

// Agar item customized hai,
// to uski final customized price use hogi.
      final menuVariation = food.menuVariation;

      if (menuVariation != null &&
          menuVariation.price != null &&
          menuVariation.price!.isNotEmpty) {
        selectedPrice =
            double.tryParse(menuVariation.price!) ??
                dineInPrice;
      } else {
        if (type == 'Delivery') {
          selectedPrice = deliveryPrice;
        } else if (type == 'Takeaway') {
          selectedPrice = takeawayPrice;
        } else {
          selectedPrice = dineInPrice;
        }
      }
      // ONLY UI PRICE UPDATE
      cartItems[i] = food.copyWith(
        price: selectedPrice.toString(),

        // Original prices preserve
        takeAwayPrice: takeawayPrice.toString(),
        deliveryPrice: deliveryPrice.toString(),
      );
    }
    notifyListeners();
  }
}