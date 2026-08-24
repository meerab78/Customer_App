import 'dart:convert';

class Order {
  Order({
    required this.orderDetails,
  });

  final List<OrderDetails> orderDetails;

  Order copyWith({
    List<OrderDetails>? orderDetails,
  }) {
    return Order(
      orderDetails: orderDetails ?? this.orderDetails,
    );
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderDetails: json["order_details"] == null
          ? []
          : List<OrderDetails>.from(
              json["order_details"]!.map((x) => OrderDetails.fromJson(x)),
            ),
    );
  }

  Map<String, dynamic> toJson() => {
        "order_details": orderDetails.map((x) => x.toJson()).toList(),
      };

  @override
  String toString() {
    return "$orderDetails, ";
  }
}

class OrderDetails {
  OrderDetails({
    this.id,
    required this.menuId,
    required this.menuName,
    required this.price,
    required this.takeawayPrice,
    required this.deliveryPrice,
    required this.quantity,
    required this.menuVariation,
    required this.orderDetailChoice,
    required this.dealDetails,
  });

  final int? id;
  final String? menuId;
  final String? menuName;
  final String? price;
  final String? takeawayPrice;
  final String? deliveryPrice;
  final int? quantity;
  final MenuVariation? menuVariation;
  final List<OrderDetailChoice> orderDetailChoice;
  final List<OrderDetails> dealDetails;

  bool get isDeal => dealDetails.isNotEmpty;

  OrderDetails copyWith({
    int? id,
    String? menuId,
    String? menuName,
    String? price,
    String? takeawayPrice,
    String? deliveryPrice,
    int? quantity,
    MenuVariation? menuVariation,
    List<OrderDetailChoice>? orderDetailChoice,
    List<OrderDetails>? dealDetails,
  }) {
    return OrderDetails(
      id: id ?? this.id,
      menuId: menuId ?? this.menuId,
      menuName: menuName ?? this.menuName,
      price: price ?? this.price,
      takeawayPrice: takeawayPrice ?? this.takeawayPrice,
      deliveryPrice: deliveryPrice ?? this.deliveryPrice,
      quantity: quantity ?? this.quantity,
      menuVariation: menuVariation ?? this.menuVariation,
      orderDetailChoice: orderDetailChoice ?? this.orderDetailChoice,
      dealDetails: dealDetails ?? this.dealDetails,
    );
  }

  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    return OrderDetails(
      id: json["id"],
      menuId: json["menu_id"]?.toString() ?? json["id"]?.toString(),
      menuName: json["menu_name"] ?? json["name"],
      price: json["price"]?.toString(),
      takeawayPrice: json["takeaway_price"]?.toString(),
      deliveryPrice: json["delivery_price"]?.toString(),
      quantity: json["quantity"],
      menuVariation: json["menu_variation"] == null
          ? null
          : MenuVariation.fromJson(
              Map<String, dynamic>.from(json["menu_variation"]),
            ),
      orderDetailChoice: _parseChoices(json),
      dealDetails: json["deal_details"] == null
          ? []
          : List<OrderDetails>.from(
              json["deal_details"]!.map((x) => OrderDetails.fromJson(x)),
            ),
    );
  }

  factory OrderDetails.fromDb(Map<String, dynamic> row) {
    return OrderDetails.fromJson({
      "id": row["id"],
      "menu_id": row["menu_id"],
      "name": row["name"],
      "price": row["price"],
      "takeaway_price": row["takeaway_price"],
      "delivery_price": row["delivery_price"],
      "quantity": row["quantity"],
      "menu_variation": _decodeJson(row["menu_variation"]),
      "order_detail_choice": _decodeJson(row["choices"]),
      "deal_details": _decodeJson(row["deal_details"]),
    });
  }

  Map<String, dynamic> toJson() => {
        "menu_id": menuId,
        "menu_name": menuName,
        "price": price,
        "takeaway_price": takeawayPrice,
        "delivery_price": deliveryPrice,
        "quantity": quantity,
        "menu_variation": menuVariation?.toJson(),
        "order_detail_choice":
            orderDetailChoice.map((x) => x.toJson()).toList(),
        "deal_details": dealDetails.map((x) => x.toJson()).toList(),
      };

  Map<String, dynamic> toDbMap() {
    return {
      "menu_id": int.tryParse(menuId ?? "") ?? 0,
      "name": menuName,
      "price": double.tryParse(price ?? "0") ?? 0,
      "takeaway_price": double.tryParse(takeawayPrice ?? "0") ?? 0,
      "delivery_price": double.tryParse(deliveryPrice ?? "0") ?? 0,
      "quantity": quantity ?? 1,
      "menu_variation": menuVariation == null
          ? null
          : jsonEncode(menuVariation!.toJson()),
      "choices": orderDetailChoice.isEmpty
          ? null
          : jsonEncode(orderDetailChoice.map((x) => x.toJson()).toList()),
      "deal_details": dealDetails.isEmpty
          ? null
          : jsonEncode(dealDetails.map((x) => x.toJson()).toList()),
    };
  }

  @override
  String toString() {
    return "$id, $menuId, $menuName, $price, $takeawayPrice, $deliveryPrice, $quantity, $menuVariation, $orderDetailChoice, $dealDetails, ";
  }
}

class MenuVariation {
  MenuVariation({
    required this.id,
    required this.name,
    required this.price,
    required this.note,
  });

  final String? id;
  final String? name;
  final String? price;
  final String? note;

  MenuVariation copyWith({
    String? id,
    String? name,
    String? price,
    String? note,
  }) {
    return MenuVariation(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      note: note ?? this.note,
    );
  }

  factory MenuVariation.fromJson(Map<String, dynamic> json) {
    return MenuVariation(
      id: json["id"]?.toString(),
      name: json["name"],
      price: json["price"]?.toString(),
      note: json["note"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "price": price,
        "note": note,
      };

  @override
  String toString() {
    return "$id, $name, $price, $note, ";
  }
}

class OrderDetailChoice {
  OrderDetailChoice({
    required this.choiceId,
    required this.choiceName,
    required this.price,
    required this.choiceGroupId,
    this.choiceGroupName,
  });

  final int? choiceId;
  final String? choiceName;
  final String? price;
  final String? choiceGroupId;
  final String? choiceGroupName;

  OrderDetailChoice copyWith({
    int? choiceId,
    String? choiceName,
    String? price,
    String? choiceGroupId,
    String? choiceGroupName,
  }) {
    return OrderDetailChoice(
      choiceId: choiceId ?? this.choiceId,
      choiceName: choiceName ?? this.choiceName,
      price: price ?? this.price,
      choiceGroupId: choiceGroupId ?? this.choiceGroupId,
      choiceGroupName: choiceGroupName ?? this.choiceGroupName,
    );
  }

  factory OrderDetailChoice.fromJson(Map<String, dynamic> json) {
    return OrderDetailChoice(
      choiceId: json["choice_id"] ?? json["id"],
      choiceName: json["choice_name"] ?? json["name"],
      price: json["price"]?.toString(),
      choiceGroupId: json["choice_group_id"]?.toString(),
      choiceGroupName: json["choice_group_name"],
    );
  }

  Map<String, dynamic> toJson() => {
        "choice_id": choiceId,
        "choice_name": choiceName,
        "price": price,
        "choice_group_id": choiceGroupId,
        "choice_group_name": choiceGroupName,
      };

  @override
  String toString() {
    return "$choiceId, $choiceName, $price, $choiceGroupId, $choiceGroupName, ";
  }
}

dynamic _decodeJson(dynamic value) {
  if (value == null || value.toString().isEmpty) {
    return null;
  }

  if (value is String) {
    return jsonDecode(value);
  }

  return value;
}

List<OrderDetailChoice> _parseChoices(Map<String, dynamic> json) {
  if (json["order_detail_choice"] != null) {
    return List<OrderDetailChoice>.from(
      json["order_detail_choice"].map((x) => OrderDetailChoice.fromJson(x)),
    );
  }

  final choices = <OrderDetailChoice>[];

  void addFromGroups(dynamic groups) {
    if (groups is! List) return;

    for (final group in groups) {
      final groupChoices = group["choices"];
      if (groupChoices is! List) continue;

      for (final choice in groupChoices) {
        choices.add(
          OrderDetailChoice.fromJson({
            ...Map<String, dynamic>.from(choice),
            "choice_group_id": group["id"],
            "choice_group_name": group["name"],
          }),
        );
      }
    }
  }

  addFromGroups(json["choice_groups"]);

  final variation = json["menu_variation"];
  if (variation is Map) {
    addFromGroups(variation["choice_groups"]);
  }

  return choices;
}
