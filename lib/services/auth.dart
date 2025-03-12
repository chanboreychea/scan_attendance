import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  final url = 'http://172.16.15.111:8000/api';

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$url/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
          "app_key":
              "6dcad16f83595c43a18c848484de9d3ab58ca8adf824dbb0b583afb3990d5aa1"
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> logout(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$url/v1/logout'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
