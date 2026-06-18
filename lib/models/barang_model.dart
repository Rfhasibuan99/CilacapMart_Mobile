class BarangModel {
  final int idBarang;
  final String namaBarang;
  final int hargaJual;
  final String? gambar;

  BarangModel({
    required this.idBarang,
    required this.namaBarang,
    required this.hargaJual,
    this.gambar,
  });

  factory BarangModel.fromJson(Map<String, dynamic> json) {
    return BarangModel(
      idBarang: int.tryParse(json['id_barang'].toString()) ?? 0,
      namaBarang: json['nama_barang'] ?? 'Tanpa Nama',
      hargaJual: int.tryParse(json['harga_jual'].toString()) ?? 0,
      gambar: json['gambar'],
    );
  }
}