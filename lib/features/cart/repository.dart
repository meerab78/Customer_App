import '../../core/db/local_db.dart';

class CartRepository {
  final LocalDb _localDb = LocalDb();
  // ADD TO CART

  Future<void> addToCart(
      Map<String, dynamic> cartItem,
      ) async {
    final db = await _localDb.database;

    await db.insert(
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
      int menuId,
      ) async {
    final db = await _localDb.database;

    await db.delete(
      'cartitems',
      where: 'menu_id = ?',
      whereArgs: [menuId],
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
      int menuId,
      int quantity,
      ) async {
    final db = await _localDb.database;

    await db.update(
      'cartitems',
      {
        'quantity': quantity,
      },
      where: 'menu_id = ?',
      whereArgs: [menuId],
    );
  }
}