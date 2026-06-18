import 'package:dio/dio.dart';
import '../models/barang_model.dart';

class BarangBloc {
  
  // Fungsi untuk mengambil list barang
  static Future<List<BarangModel>> getBarang() async {
    String apiUrl = 'http://localhost:8080/api/barang';

    try {
      // Mengambil data dari API CodeIgniter
      var response = await Dio().get(apiUrl);
      
      List<dynamic> listData = response.data is List ? response.data : response.data['data'];

      List<BarangModel> produk = [];

      for (int i = 0; i < listData.length; i++) {
        produk.add(BarangModel.fromJson(listData[i]));
      }

      return produk;
      
    } catch (e) {
      print("Error di BarangBloc getBarang: $e");
      return []; 
    }
  }
  
}