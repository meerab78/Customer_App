
import 'package:flutter/cupertino.dart';

import '../../core/db/local_db.dart';

class CartRepository {
  final LocalDb _localDb = LocalDb();

  // ADD TO CART
  Future<int> addToCart(
      Map<String, dynamic> cartItem,
      ) async {
    final db = await _localDb.database;

    debugPrint('DATABASE INSERT DATA: $cartItem');

    return await db.insert(
      'cartitems',
      cartItem,
    );
  }

  // GET CART ITEMS
  Future<List<Map<String, dynamic>>> getCartItems() async {
    final db = await _localDb.database;

    return await db.query(
      'cartitems',
    );
  }

  // UPDATE CART ITEM
  Future<void> updateCartItem(
      int id,
      Map<String, dynamic> cartItem,
      ) async {
    final db = await _localDb.database;

    await db.update(
      'cartitems',
      cartItem,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE CART ITEM
  Future<void> deleteCartItem(
      int id,
      ) async {
    final db = await _localDb.database;

    await db.delete(
      'cartitems',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CLEAR CART
  Future<void> clearCart() async {
    final db = await _localDb.database;

    await db.delete(
      'cartitems',
    );
  }

  // UPDATE QUANTITY
  Future<void> updateQuantity(
      int id,
      int quantity,
      ) async {
    final db = await _localDb.database;

    await db.update(
      'cartitems',
      {
        'quantity': quantity,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}