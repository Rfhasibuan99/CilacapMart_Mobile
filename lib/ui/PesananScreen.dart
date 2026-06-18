import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PesananScreen extends StatefulWidget {
  const PesananScreen({super.key});

  @override
  State<PesananScreen> createState() => _PesananScreenState();
}

class _PesananScreenState extends State<PesananScreen> {
  List<dynamic> _listPesanan = [];
  bool _isLoadingPesanan = true;

  @override
  void initState() {
    super.initState();
    _fetchDataPesanan();
  }

  Future<void> _fetchDataPesanan() async {
    try {
      // 1. Ambil user_id dari sesi login yang tersimpan di HP
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('user_id');

      // Kalau belum login atau nggak ada ID-nya, set loading false dan selesai
      if (userId == null) {
        setState(() { _isLoadingPesanan = false; });
        return;
      }

      // 2. Tembak ke API CI4, kirim user_id lewat query parameter
      Response response = await Dio().get(
        'http://localhost:8080/api/pesanan',
        queryParameters: {'user_id': userId},
      );

      setState(() {
        if (response.data is List) {
          _listPesanan = response.data;
        } else if (response.data['data'] != null) {
          _listPesanan = response.data['data'];
        }
        _isLoadingPesanan = false;
      });
    } catch (e) {
      print("Error ambil data pesanan: $e");
      setState(() {
        _isLoadingPesanan = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), 
      appBar: AppBar(
        title: const Text(
          'Daftar Riwayat Pesanan',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoadingPesanan) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_listPesanan.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada riwayat pesanan atau Anda belum login.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _listPesanan.length,
      itemBuilder: (context, index) {
        final pesanan = _listPesanan[index];
        return _buildPesananCard(pesanan);
      },
    );
  }

  Widget _buildPesananCard(dynamic pesanan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar produk
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                image: pesanan['gambar'] != null && pesanan['gambar'] != ''
                    ? DecorationImage(
                        image: NetworkImage('http://localhost:8080/api/image/${pesanan['gambar']}'),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: (pesanan['gambar'] == null || pesanan['gambar'] == '')
                  ? const Center(child: Icon(Icons.inventory_2_outlined, color: Colors.grey))
                  : null,
            ),
            const SizedBox(width: 16),

            // Detail pesanan sebelah gambar
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        pesanan['kode_pesanan'] ?? 'ORD-XXXXX',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(pesanan['status']).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          pesanan['status'] ?? 'Pending',
                          style: TextStyle(
                            color: _getStatusColor(pesanan['status']),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Total Belanja:',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${pesanan['total_harga'] ?? 0}',
                    style: const TextStyle(
                      color: Color(0xFF0D6EFD),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi pengatur warna badge status otomatis
  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'selesai':
        return Colors.green;
      case 'dikirim':
        return Colors.blue;
      case 'menunggu pembayaran':
        return Colors.orange;
      case 'dibatalkan':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}