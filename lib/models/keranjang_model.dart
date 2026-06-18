class KeranjangModel {
  final int idKeranjang;
  final int idBarang;
  final String namaBarang;
  final int hargaJual;
  final int jumlah;
  final String? gambar;

  KeranjangModel({
    required this.idKeranjang,
    required this.idBarang,
    required this.namaBarang,
    required this.hargaJual,
    required this.jumlah,
    this.gambar,
  });

  factory KeranjangModel.fromJson(Map<String, dynamic> json) {
    return KeranjangModel(
      idKeranjang: int.tryParse(json['id_keranjang'].toString()) ?? 0,
      idBarang: int.tryParse(json['id_barang'].toString()) ?? 0,
      namaBarang: json['nama_barang'] ?? 'Tanpa Nama',
      hargaJual: int.tryParse(json['harga_jual'].toString()) ?? 0,
      jumlah: int.tryParse(json['jumlah'].toString()) ?? 1,
      gambar: json['gambar'],
    );
  }
}