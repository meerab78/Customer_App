
import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';

class ApiService {
  Future<dynamic> getRequest(String url, {String? token}) async {
    try {
      final client = IOClient(
        HttpClient()
          ..badCertificateCallback = (cert, host, port) => true,
      );
      final response = await client.get(
        Uri.parse(url),
        headers: {
          if (token != null) "Authorization": "Bearer $token",
        },
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
      Map<String, dynamic> body, {
        String? token,
      }) async {
    try {
      final client = IOClient(
        HttpClient()
          ..badCertificateCallback = (cert, host, port) => true,
      );

      final response = await client.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      client.close();
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("POST Status Code: ${response.statusCode}");
        print("POST Response: ${response.body}");

        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map) {
            return decoded;
          }
        } catch (_) {
          // JSON nahi hai, neeche exception chali jayegi
        }

        throw Exception("Error Code: ${response.statusCode}");
      }
    } catch (e) {
      print("POST API Error: $e");
      throw Exception(e.toString());
    }
  }
}