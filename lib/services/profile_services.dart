import '../api_client.dart'; // Sesuaikan path ApiClient Anda
import '../models/user_model.dart';

class ProfileService {
  final ApiClient _apiClient = ApiClient();

  Future<UserModel> fetchProfileData() async {
    try {
      final response = await _apiClient.getRequest('akun');
      
      if (response.data != null) {
        final userResponse = UserResponse.fromJson(response.data);
        if (userResponse.data != null) {
          return userResponse.data!;
        }
      }
      throw "Gagal memproses data profil.";
    } catch (e) {
      throw e.toString();
    }
  }
}