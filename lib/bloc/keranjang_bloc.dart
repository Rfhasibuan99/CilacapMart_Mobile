import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/keranjang_model.dart';

class KeranjangBloc {
  
  
  static Future<List<KeranjangModel>> getKeranjang() async {
    try {
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('user_id');

      
      if (userId == null) {
        print("Silakan login terlebih dahulu.");
        return []; 
      }

      String apiUrl = 'http://localhost:8080/api/keranjang';

      var response = await Dio().get(
        apiUrl,
        queryParameters: {'user_id': userId},
      );

      List<dynamic> listData = response.data['status'] == 'success' 
          ? response.data['data'] 
          : [];

      List<KeranjangModel> keranjang = [];

      for (int i = 0; i < listData.length; i++) {
        keranjang.add(KeranjangModel.fromJson(listData[i]));
      }

      return keranjang;
      
    } catch (e) {
      print("Error di KeranjangBloc getKeranjang: $e");
      return [];
    }
  }


}