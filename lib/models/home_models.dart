class HomeResponse {
  final bool status; // Diubah ke bool agar konsisten di Flutter
  final String message;
  final HomeData data;

  HomeResponse({required this.status, required this.message, required this.data});

  factory HomeResponse.fromJson(Map<String, dynamic> json) {
    
    final rawStatus = json['status'];
    bool parsedStatus = false;

    if (rawStatus is bool) {
      parsedStatus = rawStatus;
    } else if (rawStatus is String) {
      parsedStatus = rawStatus.toLowerCase() == 'true' || rawStatus == '1' || rawStatus == '200';
    } else if (rawStatus is int) {
      parsedStatus = rawStatus == 1 || rawStatus == 200;
    }
    

    return HomeResponse(
      status: parsedStatus,
      message: json['message'] ?? '',
      data: HomeData.fromJson(json['data'] ?? {}),
    );
  }
}

class HomeData {
  final List<String> banners;
  final List<KategoriModel> categories;
  final List<BarangModel> products;

  HomeData({required this.banners, required this.categories, required this.products});

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      banners: List<String>.from(json['banners'] ?? []),
      categories: (json['categories'] as List? ?? [])
          .map((item) => KategoriModel.fromJson(item))
          .toList(),
      products: (json['products'] as List? ?? [])
          .map((item) => BarangModel.fromJson(item))
          .toList(),
    );
  }
}

class KategoriModel {
  final String nama;
  final String gambar;

  KategoriModel({required this.nama, required this.gambar});

  factory KategoriModel.fromJson(Map<String, dynamic> json) {
    return KategoriModel(
      nama: json['nama'] ?? '',
      gambar: json['gambar'] ?? '',
    );
  }
}

class BarangModel {
  final String? idBarang;
  final String namaBarang;
  final String hargaJual;
  final String gambar;

  BarangModel({
    this.idBarang,
    required this.namaBarang,
    required this.hargaJual,
    required this.gambar,
  });

  factory BarangModel.fromJson(Map<String, dynamic> json) {
    return BarangModel(
      idBarang: json['id_barang']?.toString(),
      namaBarang: json['nama_barang'] ?? 'Tanpa Nama',
      hargaJual: json['harga_jual']?.toString() ?? '0',
      gambar: json['gambar'] ?? '',
    );
  }
}