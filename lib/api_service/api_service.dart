
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/io_client.dart';

class ApiService {

  void _printPrettyJson(dynamic data, {required String title}) {
    if (!kDebugMode) return;
    try {
      final object = data is String ? jsonDecode(data) : data;
      final prettyString = const JsonEncoder.withIndent('  ').convert(object);
      developer.log('\n$prettyString', name: title);
    } catch (e) {
      developer.log('Raw output: $data', name: title);
    }
  }

  Future<dynamic> getRequest(String url, {String? token}) async {
    try {
      if (kDebugMode) {
        developer.log(url, name: 'GET URL');
      }
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
        final decoded = jsonDecode(response.body);
        _printPrettyJson(decoded, title: 'GET Response');
        return decoded;
      } else {
        print("GET Status Code: ${response.statusCode}");
        print("GET Response: ${response.body}");
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
      if (kDebugMode) {
        developer.log(url, name: 'POST URL');
        _printPrettyJson(body, title: 'POST Body');
      }
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
        final decoded = jsonDecode(response.body);
        _printPrettyJson(decoded, title: 'POST Response');
        return decoded;
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