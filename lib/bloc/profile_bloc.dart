import '../helpers/api_client.dart';
import '../models/user_model.dart';

class ProfileBloc {
  final ApiClient _apiClient = ApiClient();

  Future<UserModel> getProfileData() async {
    try {
      final jsonResponse = await _apiClient.getProfile();
      
      // Bungkus data JSON response menggunakan UserResponse bentukan dosen Anda
      final userResponse = UserResponse.fromJson(jsonResponse);

      if (userResponse.status == 1 && userResponse.data != null) {
        return userResponse.data!;
      } else {
        throw Exception(userResponse.message);
      }
    } catch (e) {
      throw Exception("Gagal memuat profil: ${e.toString()}");
    }
  }
}