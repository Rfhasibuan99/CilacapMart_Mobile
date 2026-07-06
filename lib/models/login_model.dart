class LoginModel {
  int id;
  String username;
  String email;
  String role;

  LoginModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      role: json['role'],
    );
  }
}