class ConvertPackage {
  final String packageId;
  final String name;
  final double points;
  final double amount;
  final int? restaurantId;

  ConvertPackage({
    required this.packageId,
    required this.name,
    required this.points,
    required this.amount,
    this.restaurantId,
  });

  factory ConvertPackage.fromJson(Map<String, dynamic> json) {
    return ConvertPackage(
      packageId: json['loyalty_wallet_package_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      points: double.tryParse('${json['points']}') ?? 0,
      amount: double.tryParse('${json['amount']}') ?? 0,
      restaurantId: json['restaurant_id'] is int
          ? json['restaurant_id']
          : int.tryParse('${json['restaurant_id']}'),
    );
  }
}