class RestaurantContentModel {
  final bool? success;
  final RestaurantContentData? data;

  RestaurantContentModel({this.success, this.data});

  factory RestaurantContentModel.fromJson(Map<String, dynamic> json) {
    return RestaurantContentModel(
      success: json['Success'],
      data: json['Data'] != null
          ? RestaurantContentData.fromJson(json['Data'])
          : null,
    );
  }
}

class RestaurantContentData {
  final String? aboutUs;
  final String? termsAndConditions;

  RestaurantContentData({this.aboutUs, this.termsAndConditions});

  factory RestaurantContentData.fromJson(Map<String, dynamic> json) {
    return RestaurantContentData(
      aboutUs: json['about_us'],
      termsAndConditions: json['terms_and_conditions'],
    );
  }
}