import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'pembayaran_page.dart';
import 'main_layout.dart';

class InvoicePage extends StatefulWidget {
  final int idPesanan;
  const InvoicePage({super.key, required this.idPesanan});

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  Map<String, dynamic>? _pesanan;
  List<dynamic> _detail = [];
  bool _isLoading = true;

  final Color navyBlue = const Color(0xFF003366);
  final Color accentColor = const Color(0xFF0D6EFD);

  @override
  void initState() {
    super.initState();
    _fetchDetailPesanan();
  }

  Future<void> _fetchDetailPesanan() async {
    try {
      Response response = await Dio().get(
        'http://localhost:8080/api/pesanan/detail',
        queryParameters: {'id_pesanan': widget.idPesanan},
      );

      if (!mounted) return;
      if (response.data['status'] == true) {
        setState(() {
          _pesanan = response.data['data']['pesanan'];
          _detail = response.data['data']['detail'];
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat detail pesanan.')),
        );
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading invoice: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'selesai':
        return Colors.green;
      case 'dikirim':
        return Colors.blue;
      case 'menunggu verifikasi':
        return Colors.purple;
      case 'menunggu pembayaran':
        return Colors.orange;
      case 'dibatalkan':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_pesanan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Invoice')),
        body: const Center(child: Text('Data pesanan tidak ditemukan.')),
      );
    }

    final double subtotal = double.tryParse(_pesanan!['subtotal'].toString()) ?? 0;
    final double diskon = double.tryParse(_pesanan!['diskon'].toString()) ?? 0;
    final double ongkir = double.tryParse(_pesanan!['ongkir'].toString()) ?? 0;
    final double totalHarga = double.tryParse(_pesanan!['total_harga'].toString()) ?? 0;

    final String status = _pesanan!['status'] ?? 'Menunggu Pembayaran';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Invoice ${_pesanan!['kode_pesanan']}',
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // Go back to main dashboard layout
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainLayout()),
              (route) => false,
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            Card(
              color: _getStatusColor(status).withValues(alpha: 0.08),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Status Pesanan', style: TextStyle(color: Colors.black54, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(
                          status,
                          style: TextStyle(
                            color: _getStatusColor(status),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      status.toLowerCase() == 'selesai'
                          ? Icons.check_circle
                          : status.toLowerCase() == 'menunggu pembayaran'
                              ? Icons.payment
                              : Icons.info_outline,
                      color: _getStatusColor(status),
                      size: 28,
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Rincian Pengiriman
            _buildCardTitle('Detail Pengiriman'),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0.5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Penerima', _pesanan!['penerima_pesanan'] ?? '-'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Nomor Telepon', _pesanan!['telp_pesanan'] ?? '-'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Alamat Lengkap', _pesanan!['alamat_lengkap_pesanan'] ?? '-'),
                    const Divider(height: 24),
                    _buildInfoRow('Metode Pengiriman', _pesanan!['metode_pengiriman'] ?? 'Grab'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Metode Pembayaran', _pesanan!['metode_pembayaran'] ?? 'QRIS'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Daftar Barang Dipesan
            _buildCardTitle('Rincian Produk'),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0.5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _detail.length,
                  separatorBuilder: (context, index) => const Divider(height: 20),
                  itemBuilder: (context, index) {
                    final item = _detail[index];
                    final String imgName = item['gambar'] ?? '';
                    final String imgUrl = imgName.isNotEmpty
                        ? 'http://localhost:8080/api/image/$imgName'
                        : '';

                    return Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            image: imgUrl.isNotEmpty
                                ? DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.cover)
                                : null,
                          ),
                          child: imgUrl.isEmpty
                              ? const Icon(Icons.image, color: Colors.grey)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['nama_barang'] ?? 'Produk',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rp ${item['harga_barang']} x ${item['jumlah']}',
                                style: const TextStyle(color: Colors.black54, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Rp ${(double.tryParse(item['subtotal'].toString()) ?? 0).toInt()}',
                          style: TextStyle(fontWeight: FontWeight.bold, color: navyBlue),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Ringkasan Harga
            _buildCardTitle('Ringkasan Pembayaran'),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0.5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildPriceSummaryRow('Subtotal Produk', 'Rp ${subtotal.toInt()}'),
                    const SizedBox(height: 8),
                    _buildPriceSummaryRow('Diskon Anggota', '- Rp ${diskon.toInt()}', isDiscount: true),
                    const SizedBox(height: 8),
                    _buildPriceSummaryRow('Ongkos Kirim', 'Rp ${ongkir.toInt()}'),
                    const Divider(height: 24),
                    _buildPriceSummaryRow('Total Akhir', 'Rp ${totalHarga.toInt()}', isTotal: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: status.toLowerCase() == 'menunggu pembayaran'
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PembayaranPage(
                            idPesanan: widget.idPesanan,
                            kodePesanan: _pesanan!['kode_pesanan'],
                            totalHarga: totalHarga,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: navyBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Bayar Sekarang',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildCardTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: navyBlue),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSummaryRow(String label, String value, {bool isDiscount = false, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black87 : Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 13,
            fontWeight: isTotal || isDiscount ? FontWeight.bold : FontWeight.normal,
            color: isTotal
                ? accentColor
                : isDiscount
                    ? Colors.green
                    : Colors.black87,
          ),
        ),
      ],
    );
  }
}
