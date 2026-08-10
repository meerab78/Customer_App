
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
class ApiService {
  Future<dynamic> getRequest(String url) async {
    try {
      final client = IOClient(
        HttpClient()
          ..badCertificateCallback = (cert, host, port) => true,
      );
      final response = await client.get(
        Uri.parse(url),
      );
      client.close();
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          "Error Code: ${response.statusCode}",
        );
      }
    } catch (e) {
      print("API Error: $e");
      throw Exception(e.toString());
    }
  }
  Future<dynamic> postRequest(
      String url,
      Map<String, dynamic> body,
      ) async {
    try {
      final client = IOClient(
        HttpClient()
          ..badCertificateCallback = (cert, host, port) => true,
      );

      final response = await client.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      client.close();
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("POST Status Code: ${response.statusCode}");
        print("POST Response: ${response.body}");

        throw Exception(
          "Error Code: ${response.statusCode}",
        );
      }
      // if (response.statusCode == 200) {
      //   return jsonDecode(response.body);
      // } else {
      //   throw Exception(
      //     "Error Code: ${response.statusCode}",
      //   );
      // }
    } catch (e) {
      print("POST API Error: $e");
      throw Exception(e.toString());
    }
  }
}