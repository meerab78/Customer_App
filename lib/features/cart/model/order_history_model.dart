class OrderHistory {
  final int? id;
  final String? orderId;
  final String? orderNo;
  final String subTotal;
  final String deliveryCharge;
  final String taxAmount;
  final String taxPercent;        // NEW: "16.00"
  final String total;
  final String orderDate;
  final String orderTypeName;     // "Take away" / "Delivery"
  final String orderStatus;       // "Pending" / "Preparing" / "Delivered"
  final String paymentType;       // NEW: "Cash"
  final String? deliveryAddress;  // NEW: address1 (delivery ho to)
  final List<OrderHistoryItem> items;

  OrderHistory({
    this.id,
    this.orderId,
    this.orderNo,
    required this.subTotal,
    required this.deliveryCharge,
    required this.taxAmount,
    required this.taxPercent,
    required this.total,
    required this.orderDate,
    required this.orderTypeName,
    required this.orderStatus,
    required this.paymentType,
    this.deliveryAddress,
    required this.items,
  });

  factory OrderHistory.fromJson(Map<String, dynamic> json) {
    final details = (json['order_details'] as List?) ?? [];

    // address object (delivery order me hota hai, warna null)
    String? address;
    if (json['address'] != null && json['address'] is Map) {
      address = json['address']['address1']?.toString();
    }

    return OrderHistory(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
      orderId: json['order_id']?.toString(),
      orderNo: json['order_no']?.toString(),
      subTotal: json['sub_total']?.toString() ?? '0',
      deliveryCharge: json['delivery_charge']?.toString() ?? '0',
      taxAmount: json['tax_amount']?.toString() ?? '0',
      taxPercent: json['tax_percent']?.toString() ?? '0',
      total: json['total']?.toString() ?? '0',
      orderDate: json['order_date']?.toString() ?? '',
      orderTypeName: json['order_type']?['type']?.toString() ?? '',
      orderStatus: json['order_status']?['name']?.toString() ?? '',
      paymentType: json['payment_type']?['type']?.toString() ?? '',
      deliveryAddress: address,
      items: details.map((e) => OrderHistoryItem.fromJson(e)).toList(),
    );
  }

  // "31 Aug 2026" (sirf date)
  String get formattedDate {
    try {
      final dt = DateTime.parse(orderDate).toLocal();
      const months = [
        'Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return orderDate;
    }
  }

  // "31-Aug-2026 06:26 PM" (date + time) — NEW
  String get formattedDateTime {
    try {
      final dt = DateTime.parse(orderDate).toLocal();
      const months = [
        'Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'
      ];

      // day (2 digit)
      final day = dt.day.toString().padLeft(2, '0');
      final month = months[dt.month - 1];

      // 12-hour time
      int hour = dt.hour;
      final minute = dt.minute.toString().padLeft(2, '0');
      final ampm = hour >= 12 ? 'PM' : 'AM';
      hour = hour % 12;
      if (hour == 0) hour = 12;
      final hourStr = hour.toString().padLeft(2, '0');

      return '$day-$month-${dt.year} $hourStr:$minute $ampm';
    } catch (_) {
      return orderDate;
    }
  }
}

class OrderHistoryItem {
  final String menuName;
  final String price;
  final String quantity;
  final String? variationName;        // NEW: "test", "Regular" etc
  final List<String> choiceNames;     // NEW: ["GARLIC MAYO DIP", "7UP"]

  OrderHistoryItem({
    required this.menuName,
    required this.price,
    required this.quantity,
    this.variationName,
    this.choiceNames = const [],
  });

  factory OrderHistoryItem.fromJson(Map<String, dynamic> json) {
    // variation (agar hai)
    String? variation;
    if (json['menu_variation'] != null && json['menu_variation'] is Map) {
      variation = json['menu_variation']['name']?.toString();
    }

    // choices ke naam
    final choices = <String>[];
    if (json['order_detail_choice'] != null &&
        json['order_detail_choice'] is List) {
      for (final c in (json['order_detail_choice'] as List)) {
        final name = c['choice_name']?.toString();
        if (name != null && name.isNotEmpty) {
          choices.add(name);
        }
      }
    }

    return OrderHistoryItem(
      menuName: json['menu_name']?.toString() ?? '',
      price: json['price']?.toString() ?? '0',
      quantity: json['quantity']?.toString() ?? '1',
      variationName: variation,
      choiceNames: choices,
    );
  }

  // "test, GARLIC MAYO DIP" — customization ek line me — NEW
  String get customizationText {
    final parts = <String>[];
    if (variationName != null && variationName!.isNotEmpty) {
      parts.add(variationName!);
    }
    parts.addAll(choiceNames);
    return parts.join(', ');
  }
}