class PesananModel {
  final String kodePesanan;
  final int totalHarga;
  final String status;
  final String? gambar;

  PesananModel({
    required this.kodePesanan,
    required this.totalHarga,
    required this.status,
    this.gambar,
  });

  factory PesananModel.fromJson(Map<String, dynamic> json) {
    return PesananModel(
      kodePesanan: json['kode_pesanan'] ?? 'ORD-XXX',
      totalHarga: int.tryParse(json['total_harga'].toString()) ?? 0,
      status: json['status'] ?? 'Pending',
      gambar: json['gambar'],
    );
  }
}