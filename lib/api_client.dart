import 'package:dio/dio.dart';

class ApiClient {
  final String baseUrl = 'http://localhost:8080/api/';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:8080/api/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  Future<Response> getRequest(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      return response;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Response> postRequest(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  String _handleError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout || 
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return "Koneksi ke server CilacapMart timeout. Pastikan internet/Wi-Fi menyala.";
    } 
    
    if (error.type == DioExceptionType.badResponse) {
      final responseData = error.response?.data;
      
      if (responseData is Map) {
        return responseData['message']?.toString() ?? "Terjadi kesalahan pada server backend.";
      } else if (responseData is String) {
        return responseData;
      }
      return "Terjadi kesalahan dengan status kode: ${error.response?.statusCode}";
    }
    
    if (error.type == DioExceptionType.connectionError) {
      return "Gagal terhubung ke backend. Pastikan Laragon & 'php spark serve' Anda menyala.";
    }

    return "Tidak dapat terhubung ke server. Periksa apakah server CI4 sudah dijalankan.";
  }
}