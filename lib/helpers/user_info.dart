import 'package:shared_preferences/shared_preferences.dart';

class UserInfo {
  
  Future<void> setUserId(String value) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString("userId", value);
  }

  
  Future<String?> getUserId() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("userId");
  }

  
  Future<void> logout() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.clear();
  }
}