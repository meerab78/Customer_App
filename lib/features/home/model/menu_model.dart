class MenuModel {
  MenuModel({
    required this.errorMessage,
    required this.message,
    required this.success,
    required this.data,
    required this.status,
  });

  final String? errorMessage;
  final String? message;
  final bool? success;
  final Data? data;
  final int? status;

  MenuModel copyWith({
    String? errorMessage,
    String? message,
    bool? success,
    Data? data,
    int? status,
  }) {
    return MenuModel(
      errorMessage: errorMessage ?? this.errorMessage,
      message: message ?? this.message,
      success: success ?? this.success,
      data: data ?? this.data,
      status: status ?? this.status,
    );
  }

  factory MenuModel.fromJson(Map<String, dynamic> json){
    return MenuModel(
      errorMessage: json["ErrorMessage"],
      message: json["Message"],
      success: json["Success"],
      data: json["Data"] == null ? null : Data.fromJson(json["Data"]),
      status: json["Status"],
    );
  }

  Map<String, dynamic> toJson() => {
    "ErrorMessage": errorMessage,
    "Message": message,
    "Success": success,
    "Data": data?.toJson(),
    "Status": status,
  };

  @override
  String toString(){
    return "$errorMessage, $message, $success, $data, $status, ";
  }
}

class Data {
  Data({
    required this.id,
    required this.restaurantBranchId,
    required this.name,
    required this.address,
    required this.isDelivery,
    required this.isDinein,
    required this.isFreedelivery,
    required this.isTakeaway,
    required this.taxInclude,
    required this.taxPercent,
    required this.logo,
    required this.logoUrl,
    required this.latitude,
    required this.longitude,
    required this.townId,
    required this.minimumOrderValue,
    required this.mobileNumber,
    required this.mobileNumber2,
    required this.mobileNumber3,
    required this.phoneNumber,
    required this.phoneNumber2,
    required this.phoneNumber3,
    required this.contactEmail,
    required this.deliveryFee,
    required this.serviceFee,
    required this.onlineDiscountPercent,
    required this.currency,
    required this.restaurantOpen,
    required this.openTime,
    required this.closeTime,
    required this.isOrderByTown,
    required this.facebookProfileUrl,
    required this.instagramProfileUrl,
    required this.youtubeProfileUrl,
    required this.tiktokProfileUrl,
    required this.xProfileUrl,
    required this.linkedinProfileUrl,
    required this.androidAppUrl,
    required this.iosAppUrl,
    required this.isLoyaltyPoint,
    required this.restaurantBranchMenu,
    required this.banners,
  });

  final int? id;
  final String? restaurantBranchId;
  final String? name;
  final String? address;
  final bool? isDelivery;
  final bool? isDinein;
  final bool? isFreedelivery;
  final int? isTakeaway;
  final bool? taxInclude;
  final String? taxPercent;
  final String? logo;
  final String? logoUrl;
  final String? latitude;
  final String? longitude;
  final int? townId;
  final int? minimumOrderValue;
  final dynamic mobileNumber;
  final dynamic mobileNumber2;
  final dynamic mobileNumber3;
  final String? phoneNumber;
  final dynamic phoneNumber2;
  final dynamic phoneNumber3;
  final String? contactEmail;
  final int? deliveryFee;
  final int? serviceFee;
  final int? onlineDiscountPercent;
  final String? currency;
  final bool? restaurantOpen;
  final String? openTime;
  final String? closeTime;
  final int? isOrderByTown;
  final String? facebookProfileUrl;
  final String? instagramProfileUrl;
  final String? youtubeProfileUrl;
  final String? tiktokProfileUrl;
  final String? xProfileUrl;
  final String? linkedinProfileUrl;
  final String? androidAppUrl;
  final String? iosAppUrl;
  final int? isLoyaltyPoint;
  final List<RestaurantBranchMenu> restaurantBranchMenu;
  final List<Banner> banners;

  Data copyWith({
    int? id,
    String? restaurantBranchId,
    String? name,
    String? address,
    bool? isDelivery,
    bool? isDinein,
    bool? isFreedelivery,
    int? isTakeaway,
    bool? taxInclude,
    String? taxPercent,
    String? logo,
    String? logoUrl,
    String? latitude,
    String? longitude,
    int? townId,
    int? minimumOrderValue,
    dynamic? mobileNumber,
    dynamic? mobileNumber2,
    dynamic? mobileNumber3,
    String? phoneNumber,
    dynamic? phoneNumber2,
    dynamic? phoneNumber3,
    String? contactEmail,
    int? deliveryFee,
    int? serviceFee,
    int? onlineDiscountPercent,
    String? currency,
    bool? restaurantOpen,
    String? openTime,
    String? closeTime,
    int? isOrderByTown,
    String? facebookProfileUrl,
    String? instagramProfileUrl,
    String? youtubeProfileUrl,
    String? tiktokProfileUrl,
    String? xProfileUrl,
    String? linkedinProfileUrl,
    String? androidAppUrl,
    String? iosAppUrl,
    int? isLoyaltyPoint,
    List<RestaurantBranchMenu>? restaurantBranchMenu,
    List<Banner>? banners,
  }) {
    return Data(
      id: id ?? this.id,
      restaurantBranchId: restaurantBranchId ?? this.restaurantBranchId,
      name: name ?? this.name,
      address: address ?? this.address,
      isDelivery: isDelivery ?? this.isDelivery,
      isDinein: isDinein ?? this.isDinein,
      isFreedelivery: isFreedelivery ?? this.isFreedelivery,
      isTakeaway: isTakeaway ?? this.isTakeaway,
      taxInclude: taxInclude ?? this.taxInclude,
      taxPercent: taxPercent ?? this.taxPercent,
      logo: logo ?? this.logo,
      logoUrl: logoUrl ?? this.logoUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      townId: townId ?? this.townId,
      minimumOrderValue: minimumOrderValue ?? this.minimumOrderValue,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      mobileNumber2: mobileNumber2 ?? this.mobileNumber2,
      mobileNumber3: mobileNumber3 ?? this.mobileNumber3,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      phoneNumber2: phoneNumber2 ?? this.phoneNumber2,
      phoneNumber3: phoneNumber3 ?? this.phoneNumber3,
      contactEmail: contactEmail ?? this.contactEmail,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      serviceFee: serviceFee ?? this.serviceFee,
      onlineDiscountPercent: onlineDiscountPercent ?? this.onlineDiscountPercent,
      currency: currency ?? this.currency,
      restaurantOpen: restaurantOpen ?? this.restaurantOpen,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      isOrderByTown: isOrderByTown ?? this.isOrderByTown,
      facebookProfileUrl: facebookProfileUrl ?? this.facebookProfileUrl,
      instagramProfileUrl: instagramProfileUrl ?? this.instagramProfileUrl,
      youtubeProfileUrl: youtubeProfileUrl ?? this.youtubeProfileUrl,
      tiktokProfileUrl: tiktokProfileUrl ?? this.tiktokProfileUrl,
      xProfileUrl: xProfileUrl ?? this.xProfileUrl,
      linkedinProfileUrl: linkedinProfileUrl ?? this.linkedinProfileUrl,
      androidAppUrl: androidAppUrl ?? this.androidAppUrl,
      iosAppUrl: iosAppUrl ?? this.iosAppUrl,
      isLoyaltyPoint: isLoyaltyPoint ?? this.isLoyaltyPoint,
      restaurantBranchMenu: restaurantBranchMenu ?? this.restaurantBranchMenu,
      banners: banners ?? this.banners,
    );
  }

  factory Data.fromJson(Map<String, dynamic> json){
    return Data(
      id: json["id"],
      restaurantBranchId: json["restaurant_branch_id"],
      name: json["name"],
      address: json["address"],
      isDelivery: json["is_delivery"],
      isDinein: json["is_dinein"],
      isFreedelivery: json["is_freedelivery"],
      isTakeaway: json["is_takeaway"],
      taxInclude: json["tax_include"],
      taxPercent: json["tax_percent"],
      logo: json["logo"],
      logoUrl: json["logo_url"],
      latitude: json["latitude"],
      longitude: json["longitude"],
      townId: json["town_id"],
      minimumOrderValue: json["minimum_order_value"],
      mobileNumber: json["mobile_number"],
      mobileNumber2: json["mobile_number2"],
      mobileNumber3: json["mobile_number3"],
      phoneNumber: json["phone_number"],
      phoneNumber2: json["phone_number2"],
      phoneNumber3: json["phone_number3"],
      contactEmail: json["contact_email"],
      deliveryFee: json["delivery_fee"],
      serviceFee: json["service_fee"],
      onlineDiscountPercent: json["online_discount_percent"],
      currency: json["currency"],
      restaurantOpen: json["restaurant_open"],
      openTime: json["open_time"],
      closeTime: json["close_time"],
      isOrderByTown: json["is_order_by_town"],
      facebookProfileUrl: json["facebook_profile_url"],
      instagramProfileUrl: json["instagram_profile_url"],
      youtubeProfileUrl: json["youtube_profile_url"],
      tiktokProfileUrl: json["tiktok_profile_url"],
      xProfileUrl: json["x_profile_url"],
      linkedinProfileUrl: json["linkedin_profile_url"],
      androidAppUrl: json["android_app_url"],
      iosAppUrl: json["ios_app_url"],
      isLoyaltyPoint: json["is_loyalty_point"],
      restaurantBranchMenu: json["restaurant_branch_menu"] == null ? [] : List<RestaurantBranchMenu>.from(json["restaurant_branch_menu"]!.map((x) => RestaurantBranchMenu.fromJson(x))),
      banners: json["banners"] == null ? [] : List<Banner>.from(json["banners"]!.map((x) => Banner.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "restaurant_branch_id": restaurantBranchId,
    "name": name,
    "address": address,
    "is_delivery": isDelivery,
    "is_dinein": isDinein,
    "is_freedelivery": isFreedelivery,
    "is_takeaway": isTakeaway,
    "tax_include": taxInclude,
    "tax_percent": taxPercent,
    "logo": logo,
    "logo_url": logoUrl,
    "latitude": latitude,
    "longitude": longitude,
    "town_id": townId,
    "minimum_order_value": minimumOrderValue,
    "mobile_number": mobileNumber,
    "mobile_number2": mobileNumber2,
    "mobile_number3": mobileNumber3,
    "phone_number": phoneNumber,
    "phone_number2": phoneNumber2,
    "phone_number3": phoneNumber3,
    "contact_email": contactEmail,
    "delivery_fee": deliveryFee,
    "service_fee": serviceFee,
    "online_discount_percent": onlineDiscountPercent,
    "currency": currency,
    "restaurant_open": restaurantOpen,
    "open_time": openTime,
    "close_time": closeTime,
    "is_order_by_town": isOrderByTown,
    "facebook_profile_url": facebookProfileUrl,
    "instagram_profile_url": instagramProfileUrl,
    "youtube_profile_url": youtubeProfileUrl,
    "tiktok_profile_url": tiktokProfileUrl,
    "x_profile_url": xProfileUrl,
    "linkedin_profile_url": linkedinProfileUrl,
    "android_app_url": androidAppUrl,
    "ios_app_url": iosAppUrl,
    "is_loyalty_point": isLoyaltyPoint,
    "restaurant_branch_menu": restaurantBranchMenu.map((x) => x?.toJson()).toList(),
    "banners": banners.map((x) => x?.toJson()).toList(),
  };

  @override
  String toString(){
    return "$id, $restaurantBranchId, $name, $address, $isDelivery, $isDinein, $isFreedelivery, $isTakeaway, $taxInclude, $taxPercent, $logo, $logoUrl, $latitude, $longitude, $townId, $minimumOrderValue, $mobileNumber, $mobileNumber2, $mobileNumber3, $phoneNumber, $phoneNumber2, $phoneNumber3, $contactEmail, $deliveryFee, $serviceFee, $onlineDiscountPercent, $currency, $restaurantOpen, $openTime, $closeTime, $isOrderByTown, $facebookProfileUrl, $instagramProfileUrl, $youtubeProfileUrl, $tiktokProfileUrl, $xProfileUrl, $linkedinProfileUrl, $androidAppUrl, $iosAppUrl, $isLoyaltyPoint, $restaurantBranchMenu, $banners, ";
  }
}

class Banner {
  Banner({
    required this.id,
    required this.name,
    required this.image,
    required this.imageUrl,
  });

  final int? id;
  final String? name;
  final String? image;
  final String? imageUrl;

  Banner copyWith({
    int? id,
    String? name,
    String? image,
    String? imageUrl,
  }) {
    return Banner(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  factory Banner.fromJson(Map<String, dynamic> json){
    return Banner(
      id: json["id"],
      name: json["name"],
      image: json["image"],
      imageUrl: json["image_url"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "image": image,
    "image_url": imageUrl,
  };

  @override
  String toString(){
    return "$id, $name, $image, $imageUrl, ";
  }
}

class RestaurantBranchMenu {
  RestaurantBranchMenu({
    required this.menuCategoryId,
    required this.name,
    required this.image,
    required this.imageUrl,
    required this.menu,
  });

  final String? menuCategoryId;
  final String? name;
  final String? image;
  final String? imageUrl;
  final List<Menu> menu;

  RestaurantBranchMenu copyWith({
    String? menuCategoryId,
    String? name,
    String? image,
    String? imageUrl,
    List<Menu>? menu,
  }) {
    return RestaurantBranchMenu(
      menuCategoryId: menuCategoryId ?? this.menuCategoryId,
      name: name ?? this.name,
      image: image ?? this.image,
      imageUrl: imageUrl ?? this.imageUrl,
      menu: menu ?? this.menu,
    );
  }

  factory RestaurantBranchMenu.fromJson(Map<String, dynamic> json){
    return RestaurantBranchMenu(
      menuCategoryId: json["menu_category_id"],
      name: json["name"],
      image: json["image"],
      imageUrl: json["image_url"],
      menu: json["menu"] == null ? [] : List<Menu>.from(json["menu"]!.map((x) => Menu.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "menu_category_id": menuCategoryId,
    "name": name,
    "image": image,
    "image_url": imageUrl,
    "menu": menu.map((x) => x?.toJson()).toList(),
  };

  @override
  String toString(){
    return "$menuCategoryId, $name, $image, $imageUrl, $menu, ";
  }
}

class Menu {
  Menu({
    required this.id,
    required this.menuId,
    required this.name,
    required this.price,
    required this.takeAwayPrice,
    required this.deliveryPrice,
    required this.image,
    required this.imageUrl,
    required this.description,
    required this.ingridient,
    required this.isDeal,
    required this.menuVariations,
    required this.choiceGroup,
    required this.dealMenuDetails,
    required this.quantity,
    required this.menuVariation,
  });

  final int? id;
  final String? menuId;
  final String? name;
  final String? price;
  final String? takeAwayPrice;
  final String? deliveryPrice;
  final String? image;
  final String? imageUrl;
  final String? description;
  final dynamic ingridient;
  final bool? isDeal;
  final List<MenuVariation> menuVariations;
  final List<ChoiceGroup> choiceGroup;
  final List<Menu> dealMenuDetails;
  final int? quantity;
  final MenuVariation? menuVariation;

  Menu copyWith({
    int? id,
    String? menuId,
    String? name,
    String? price,
    String? takeAwayPrice,
    String? deliveryPrice,
    String? image,
    String? imageUrl,
    String? description,
    dynamic? ingridient,
    bool? isDeal,
    List<MenuVariation>? menuVariations,
    List<ChoiceGroup>? choiceGroup,
    List<Menu>? dealMenuDetails,
    int? quantity,
    MenuVariation? menuVariation,
  }) {
    return Menu(
      id: id ?? this.id,
      menuId: menuId ?? this.menuId,
      name: name ?? this.name,
      price: price ?? this.price,
      takeAwayPrice: takeAwayPrice ?? this.takeAwayPrice,
      deliveryPrice: deliveryPrice ?? this.deliveryPrice,
      image: image ?? this.image,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      ingridient: ingridient ?? this.ingridient,
      isDeal: isDeal ?? this.isDeal,
      menuVariations: menuVariations ?? this.menuVariations,
      choiceGroup: choiceGroup ?? this.choiceGroup,
      dealMenuDetails: dealMenuDetails ?? this.dealMenuDetails,
      quantity: quantity ?? this.quantity,
      menuVariation: menuVariation ?? this.menuVariation,
    );
  }

  factory Menu.fromJson(Map<String, dynamic> json){
    return Menu(
      id: json["id"],
      menuId: json["menu_id"],
      name: json["name"],
      price: json["price"],
      takeAwayPrice: json["take_away_price"],
      deliveryPrice: json["delivery_price"],
      image: json["image"],
      imageUrl: json["image_url"],
      description: json["description"],
      ingridient: json["ingridient"],
      isDeal: json["is_deal"],
      menuVariations: json["menu_variations"] == null ? [] : List<MenuVariation>.from(json["menu_variations"]!.map((x) => MenuVariation.fromJson(x))),
      choiceGroup: json["choice_group"] == null ? [] : List<ChoiceGroup>.from(json["choice_group"]!.map((x) => ChoiceGroup.fromJson(x))),
      dealMenuDetails: json["deal_menu_details"] == null ? [] : List<Menu>.from(json["deal_menu_details"]!.map((x) => Menu.fromJson(x))),
      quantity: json["quantity"],
      menuVariation: json["menu_variation"] == null ? null : MenuVariation.fromJson(json["menu_variation"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "menu_id": menuId,
    "name": name,
    "price": price,
    "take_away_price": takeAwayPrice,
    "delivery_price": deliveryPrice,
    "image": image,
    "image_url": imageUrl,
    "description": description,
    "ingridient": ingridient,
    "is_deal": isDeal,
    "menu_variations": menuVariations.map((x) => x?.toJson()).toList(),
    "choice_group": choiceGroup.map((x) => x?.toJson()).toList(),
    "deal_menu_details": dealMenuDetails.map((x) => x?.toJson()).toList(),
    "quantity": quantity,
    "menu_variation": menuVariation?.toJson(),
  };

  @override
  String toString(){
    return "$id, $menuId, $name, $price, $takeAwayPrice, $deliveryPrice, $image, $imageUrl, $description, $ingridient, $isDeal, $menuVariations, $choiceGroup, $dealMenuDetails, $quantity, $menuVariation, ";
  }
}

class MenuVariation {
  MenuVariation({
    required this.id,
    required this.name,
    required this.price,
    required this.takeAwayPrice,
    required this.deliveryPrice,
    required this.choiceGroups,
  });

  final int? id;
  final String? name;
  final String? price;
  final String? takeAwayPrice;
  final String? deliveryPrice;
  final List<ChoiceGroup> choiceGroups;

  MenuVariation copyWith({
    int? id,
    String? name,
    String? price,
    String? takeAwayPrice,
    String? deliveryPrice,
    List<ChoiceGroup>? choiceGroups,
  }) {
    return MenuVariation(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      takeAwayPrice: takeAwayPrice ?? this.takeAwayPrice,
      deliveryPrice: deliveryPrice ?? this.deliveryPrice,
      choiceGroups: choiceGroups ?? this.choiceGroups,
    );
  }

  factory MenuVariation.fromJson(Map<String, dynamic> json){
    return MenuVariation(
      id: json["id"],
      name: json["name"],
      price: json["price"],
      takeAwayPrice: json["take_away_price"],
      deliveryPrice: json["delivery_price"],
      choiceGroups: json["choice_groups"] == null ? [] : List<ChoiceGroup>.from(json["choice_groups"]!.map((x) => ChoiceGroup.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "price": price,
    "take_away_price": takeAwayPrice,
    "delivery_price": deliveryPrice,
    "choice_groups": choiceGroups.map((x) => x?.toJson()).toList(),
  };

  @override
  String toString(){
    return "$id, $name, $price, $takeAwayPrice, $deliveryPrice, $choiceGroups, ";
  }
}

class ChoiceGroup {
  ChoiceGroup({
    required this.id,
    required this.name,
    required this.minChoices,
    required this.maxChoices,
    required this.choices,
  });

  final int? id;
  final String? name;
  final int? minChoices;
  final int? maxChoices;
  final List<MenuVariation> choices;

  ChoiceGroup copyWith({
    int? id,
    String? name,
    int? minChoices,
    int? maxChoices,
    List<MenuVariation>? choices,
  }) {
    return ChoiceGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      minChoices: minChoices ?? this.minChoices,
      maxChoices: maxChoices ?? this.maxChoices,
      choices: choices ?? this.choices,
    );
  }

  factory ChoiceGroup.fromJson(Map<String, dynamic> json){
    return ChoiceGroup(
      id: json["id"],
      name: json["name"],
      minChoices: json["min_choices"],
      maxChoices: json["max_choices"],
      choices: json["choices"] == null ? [] : List<MenuVariation>.from(json["choices"]!.map((x) => MenuVariation.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "min_choices": minChoices,
    "max_choices": maxChoices,
    "choices": choices.map((x) => x?.toJson()).toList(),
  };

  @override
  String toString(){
    return "$id, $name, $minChoices, $maxChoices, $choices, ";
  }
}
