import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_info.dart';

class ApiClient {
  final String baseUrl = "http://192.168.1.4:8080/api";

  Future<Map<String, dynamic>> getProfile() async {
    
    String? userId = await UserInfo().getUserId();
    
    if (userId == null || userId.isEmpty) {
      throw Exception("User ID tidak ditemukan. Silakan login kembali.");
    }

    final response = await http.get(
      Uri.parse('$baseUrl/akun/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? "Gagal memuat data profil.");
    }
  }
}