import 'package:flutter/cupertino.dart';

import 'local_db.dart';
import 'model.dart';

class DbController extends ChangeNotifier {
  final LocalDb _localDb = LocalDb();

  // ADD TO CART
  Future<int> addToCart(OrderDetails item) async {
    final db = await _localDb.database;

    debugPrint('DATABASE INSERT DATA: ${item.toDbMap()}');

    final id = await db.insert(
      'cartitems',
      item.toDbMap(),
    );

    notifyListeners();
    return id;
  }

  // GET CART
  Future<List<OrderDetails>> getCart() async {
    final db = await _localDb.database;

    final rows = await db.query(
      'cartitems',
    );

    return rows.map((row) => OrderDetails.fromDb(row)).toList();
  }

  // UPDATE CART
  Future<void> updateCart(
    int id,
    OrderDetails item,
  ) async {
    final db = await _localDb.database;

    await db.update(
      'cartitems',
      item.toDbMap(),
      where: 'id = ?',
      whereArgs: [id],
    );

    notifyListeners();
  }

  // DELETE CART
  Future<void> deleteCart(int id) async {
    final db = await _localDb.database;

    await db.delete(
      'cartitems',
      where: 'id = ?',
      whereArgs: [id],
    );

    notifyListeners();
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

    notifyListeners();
  }

  // CLEAR CART
  Future<void> clearCart() async {
    final db = await _localDb.database;

    await db.delete(
      'cartitems',
    );

    notifyListeners();
  }
}
