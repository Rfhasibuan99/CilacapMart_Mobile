class UserResponse {
  final dynamic status;
  final String message;
  final UserModel? data;

  UserResponse({required this.status, required this.message, this.data});

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      status: json['status'],
      message: json['message'] ?? '',
      data: json['data'] != null ? UserModel.fromJson(json['data']) : null,
    );
  }
}

class UserModel {
  final String id;
  final String username;
  final String email;
  final String namaPengguna;
  final String alamat;
  final String noTlp;
  final String jenisKelamin;
  final String? tglLahir;
  final String? gambar;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.namaPengguna,
    required this.alamat,
    required this.noTlp,
    required this.jenisKelamin,
    this.tglLahir,
    this.gambar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      namaPengguna: json['nama_pengguna'] ?? 'Nama Pengguna',
      alamat: json['alamat'] ?? '-',
      noTlp: json['no_tlp'] ?? '-',
      jenisKelamin: json['jenis_kelamin'] ?? '-',
      tglLahir: json['tgl_lahir'],
      gambar: json['gambar'],
    );
  }
}