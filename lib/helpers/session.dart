import 'package:shared_preferences/shared_preferences.dart';

class Session {

  static Future saveUser(
    int id,
    String username,
    String email,
    String role,
  ) async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('id', id);
    await prefs.setString('username', username);
    await prefs.setString('email', email);
    await prefs.setString('role', role);
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  static Future logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}