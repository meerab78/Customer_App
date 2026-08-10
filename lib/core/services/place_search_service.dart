import 'dart:convert';
import 'package:http/http.dart' as http;

class PlaceSearchService {

  static const String apiKey = "AIzaSyBUbCbmkNfSvQ8nflO64lgaIowblekfTrc";
  Future<List<dynamic>> searchPlaces(String query) async {
    if (query.isEmpty) {
      return [];
    }
    final url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json"
        "?input=$query"
        "&key=AIzaSyBUbCbmkNfSvQ8nflO64lgaIowblekfTrc"
        "&components=country:pk";
    final response = await http.get(
      Uri.parse(url),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["predictions"];
    }
    return [];
  }
  Future<Map<String, dynamic>?> getPlaceDetails(
      String placeId,
      ) async {
    final url =
        "https://maps.googleapis.com/maps/api/place/details/json"
        "?place_id=$placeId"
        "&key=AIzaSyBUbCbmkNfSvQ8nflO64lgaIowblekfTrc";
    final response = await http.get(
      Uri.parse(url),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["result"];
    }
    return null;
  }
}