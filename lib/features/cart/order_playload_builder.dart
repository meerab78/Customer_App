import '../../core/db/sqflite/model.dart';

/// Cart + address + branch/tax data ko exact `place_order` JSON payload mein
/// convert karta hai. Pure static builder hai -- kisi controller/repository
/// se independent, taake reuse/test karna aasan rahe.
class OrderPayloadBuilder {
  static Map<String, dynamic> build({
    required List<OrderDetails> cartItems,
    required String orderType, // 'Takeaway' or 'Delivery'
    required String customerId,
    required String branchId,
    required double subTotal,
    required double taxPercent,
    required bool taxInclude,
    required double deliveryFee,
    String? deliveryAddressId,
  }) {
    final bool isDelivery = orderType == 'Delivery';
    final int orderTypeId = isDelivery ? 3 : 2;

    // tax_include is API mein hamesha true hota hai, lekin formula dono
    // cases handle karta hai taake future-proof rahe.
    final double taxAmount = taxInclude
        ? (subTotal * taxPercent) / (100 + taxPercent)
        : (subTotal * taxPercent) / 100;

    final double deliveryCharge = isDelivery ? deliveryFee : 0.0;
    final double total = subTotal + deliveryCharge;

    return {
      "notes": "",
      "order_resource": "3",
      "restaurant_branch_id": branchId,
      "customer_id": int.tryParse(customerId) ?? customerId,
      "discount_amount": "0",
      "discount_per": "0",
      "discount_id": null,
      "coupon_id": null,
      "tax_amount": double.parse(taxAmount.toStringAsFixed(2)),
      "tax_percent": taxPercent.toStringAsFixed(2),
      "tax_include": taxInclude ? "1" : "0",
      "delivery_charge": deliveryCharge.toStringAsFixed(2),
      "total": total.toStringAsFixed(2),
      "cash_amount": total.toStringAsFixed(2),
      "wallet_amount": "0",
      "sub_total": subTotal.toStringAsFixed(2),
      "order_type_id": orderTypeId,
      "payment_type_id": 1,
      "delivery_address_id": isDelivery
          ? (int.tryParse(deliveryAddressId ?? '') ?? 0)
          : 0,
      "order_details":
      cartItems.map((item) => _buildItem(item, isTopLevel: true)).toList(),
    };
  }

  /// isTopLevel=true  -> normal cart item, real price, "deal_details" key hoti hai
  /// isTopLevel=false -> deal sub-item, price forced "0.00" (already parent ki
  ///                     price mein shamil), "deal_details" key bilkul nahi hoti
  static Map<String, dynamic> _buildItem(
      OrderDetails item, {
        required bool isTopLevel,
      }) {
    final map = <String, dynamic>{
      "menu_id": item.menuId,
      "menu_name": item.menuName,
      "price": isTopLevel ? (item.price ?? "0") : "0.00",
      "quantity": item.quantity ?? 1,
      "menu_variation": item.menuVariation == null
          ? {"id": "", "name": "", "price": "0", "note": ""}
          : {
        "id": item.menuVariation!.id ?? "",
        "name": item.menuVariation!.name ?? "",
        "price": item.menuVariation!.price ?? "0",
        "note": item.menuVariation!.note ?? "",
      },
      "order_detail_choice": item.orderDetailChoice
          .map((c) => {
        "choice_id": c.choiceId,
        "choice_name": c.choiceName,
        "price": c.price ?? "0",
        "choice_group_id": c.choiceGroupId,
      })
          .toList(),
    };

    if (isTopLevel) {
      map["deal_details"] = item.dealDetails
          .map((d) => _buildItem(d, isTopLevel: false))
          .toList();
    }

    return map;
  }
}