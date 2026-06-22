import 'package:shared_preferences/shared_preferences.dart';

class UserInfo {
  // Fungsi untuk menyimpan ID User (Dipanggil saat LOGIN BERHASIL)
  Future<void> setUserId(String value) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString("userId", value);
  }

  // Fungsi untuk mengambil ID User (Dipanggil oleh ApiClient / ProfileBloc)
  Future<String?> getUserId() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("userId");
  }

  // Fungsi untuk menghapus sesi (Dipanggil saat LOGOUT)
  Future<void> logout() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.clear();
  }
}