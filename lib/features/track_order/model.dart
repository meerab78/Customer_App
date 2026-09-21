class OrderTrackingResponse {
  OrderTrackingResponse({
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

  OrderTrackingResponse copyWith({
    String? errorMessage,
    String? message,
    bool? success,
    Data? data,
    int? status,
  }) {
    return OrderTrackingResponse(
      errorMessage: errorMessage ?? this.errorMessage,
      message: message ?? this.message,
      success: success ?? this.success,
      data: data ?? this.data,
      status: status ?? this.status,
    );
  }

  factory OrderTrackingResponse.fromJson(Map<String, dynamic> json) {
    return OrderTrackingResponse(
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
  String toString() {
    return "$errorMessage, $message, $success, $data, $status, ";
  }
}

class Data {
  Data({
    required this.startLatitude,
    required this.startLongitude,
    required this.currentLatitude,
    required this.currentLongitude,
    required this.endLatitude,
    required this.endLongitude,
    required this.address,
    required this.riderName,
    required this.riderContactno,
  });

  final String? startLatitude;
  final String? startLongitude;
  final String? currentLatitude;
  final String? currentLongitude;
  final String? endLatitude;
  final String? endLongitude;
  final String? address;
  final String? riderName;
  final String? riderContactno;

  Data copyWith({
    String? startLatitude,
    String? startLongitude,
    String? currentLatitude,
    String? currentLongitude,
    String? endLatitude,
    String? endLongitude,
    String? address,
    String? riderName,
    String? riderContactno,
  }) {
    return Data(
      startLatitude: startLatitude ?? this.startLatitude,
      startLongitude: startLongitude ?? this.startLongitude,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      endLatitude: endLatitude ?? this.endLatitude,
      endLongitude: endLongitude ?? this.endLongitude,
      address: address ?? this.address,
      riderName: riderName ?? this.riderName,
      riderContactno: riderContactno ?? this.riderContactno,
    );
  }

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      startLatitude: json["start_latitude"],
      startLongitude: json["start_longitude"],
      currentLatitude: json["current_latitude"],
      currentLongitude: json["current_longitude"],
      endLatitude: json["end_latitude"],
      endLongitude: json["end_longitude"],
      address: json["address"],
      riderName: json["rider_name"],
      riderContactno: json["rider_contactno"],
    );
  }

  Map<String, dynamic> toJson() => {
        "start_latitude": startLatitude,
        "start_longitude": startLongitude,
        "current_latitude": currentLatitude,
        "current_longitude": currentLongitude,
        "end_latitude": endLatitude,
        "end_longitude": endLongitude,
        "address": address,
        "rider_name": riderName,
        "rider_contactno": riderContactno,
      };

  @override
  String toString() {
    return "$startLatitude, $startLongitude, $currentLatitude, $currentLongitude, $endLatitude, $endLongitude, $address, $riderName, $riderContactno, ";
  }
}

/*
{
	"ErrorMessage": "Success!",
	"Message": "Success!",
	"Success": true,
	"Data": {
		"start_latitude": null,
		"start_longitude": null,
		"current_latitude": null,
		"current_longitude": null,
		"end_latitude": "32.5176033",
		"end_longitude": "74.5305189",
		"address": null,
		"rider_name": "umer tariq tariq",
		"rider_contactno": "03049560006"
	},
	"Status": 200
}*/
