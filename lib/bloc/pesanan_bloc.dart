import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pesanan_model.dart'; 

class PesananBloc {
  
  
  static Future<List<PesananModel>> getPesanan() async {
    try {
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('user_id');

      
      if (userId == null) {
        print("Belum login, tidak bisa mengambil riwayat pesanan.");
        return [];
      }

      String apiUrl = 'http://localhost:8080/api/pesanan';

      var response = await Dio().get(
        apiUrl,
        queryParameters: {'user_id': userId},
      );
      
      List<dynamic> listData = response.data is List 
          ? response.data 
          : response.data['data'] ?? [];

      List<PesananModel> pesanan = [];

      for (int i = 0; i < listData.length; i++) {
        pesanan.add(PesananModel.fromJson(listData[i]));
      }

      return pesanan;
      
    } catch (e) {
      print("Error di PesananBloc getPesanan: $e");
      return [];
    }
  }
  
}