double pickOrderTypePrice({
  required String orderType,
  required String? dinePrice,
  String? takeawayPrice,
  String? deliveryPrice,
}) {
  final dine = double.tryParse(dinePrice ?? '0') ?? 0;
  switch (orderType) {
    case 'Takeaway':
      return double.tryParse(takeawayPrice ?? dinePrice ?? '0') ?? dine;
    case 'Delivery':
      return double.tryParse(deliveryPrice ?? dinePrice ?? '0') ?? dine;
    default:
      return dine;
  }
}