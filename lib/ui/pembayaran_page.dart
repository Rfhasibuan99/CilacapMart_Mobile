import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'invoice_page.dart';

class PembayaranPage extends StatefulWidget {
  final int idPesanan;
  final String kodePesanan;
  final double totalHarga;

  const PembayaranPage({
    super.key,
    required this.idPesanan,
    required this.kodePesanan,
    required this.totalHarga,
  });

  @override
  State<PembayaranPage> createState() => _PembayaranPageState();
}

class _PembayaranPageState extends State<PembayaranPage> {
  bool _isProcessing = false;

  final Color navyBlue = const Color(0xFF003366);
  final Color accentColor = const Color(0xFF0D6EFD);

  Future<void> _konfirmasiPembayaran() async {
    setState(() => _isProcessing = true);

    try {
      Response response = await Dio().post(
        'http://localhost:8080/api/pesanan/update_status_pembayaran',
        data: {
          'id_pesanan': widget.idPesanan,
          'status': 'Menunggu Verifikasi',
        },
      );

      if (response.data['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Konfirmasi berhasil dikirim. Menunggu verifikasi admin.'),
            backgroundColor: Colors.green,
          ),
        );

        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => InvoicePage(idPesanan: widget.idPesanan),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data['message'] ?? 'Gagal memproses pembayaran.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error confirming payment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal terhubung ke server. Pastikan server Anda aktif.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Pembayaran',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Text(
              'Total Pembayaran',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Rp ${widget.totalHarga.toInt()}',
              style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 32,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Order ID: ${widget.kodePesanan}',
                style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 30),

            // QRIS Scan Mockup
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[200]!, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Image.network(
                    'https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=CilacapMartPayment-${widget.kodePesanan}',
                    height: 200,
                    width: 200,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const SizedBox(
                        height: 200,
                        width: 200,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.qr_code_2, size: 200, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'SCAN QRIS UNTUK MEMBAYAR',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'CilacapMart Official Merchant',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Petunjuk Pembayaran
            Card(
              color: const Color(0xFFF8FAFC),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Petunjuk Pembayaran:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: navyBlue),
                    ),
                    const SizedBox(height: 10),
                    _buildStepRow(1, 'Simpan / Screenshot kode QRIS di atas.'),
                    const SizedBox(height: 8),
                    _buildStepRow(2, 'Buka aplikasi e-wallet Anda (Gopay, OVO, Dana, LinkAja) atau Mobile Banking.'),
                    const SizedBox(height: 8),
                    _buildStepRow(3, 'Pilih menu "Bayar" atau "Scan QR" lalu unggah gambar QRIS yang telah Anda simpan.'),
                    const SizedBox(height: 8),
                    _buildStepRow(4, 'Periksa nominal pembayaran dan selesaikan transaksi.'),
                    const SizedBox(height: 8),
                    _buildStepRow(5, 'Setelah berhasil membayar, tekan tombol "Konfirmasi Pembayaran" di bawah ini.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _konfirmasiPembayaran,
                style: ElevatedButton.styleFrom(
                  backgroundColor: navyBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text(
                        'Konfirmasi Pembayaran',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStepRow(int number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 10,
          backgroundColor: navyBlue,
          child: Text(
            '$number',
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
