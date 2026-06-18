import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KeranjangScreen extends StatefulWidget {
  const KeranjangScreen({super.key});

  @override
  State<KeranjangScreen> createState() => _KeranjangScreenState();
}

class _KeranjangScreenState extends State<KeranjangScreen> {
  List<dynamic> _listKeranjang = [];
  bool _isLoading = true;
  double _totalBelanja = 0;

  @override
  void initState() {
    super.initState();
    _fetchDataKeranjang();
  }

  // Fungsi untuk mengambil data keranjang dari API
  Future<void> _fetchDataKeranjang() async {
    try {
      // 1. Ambil user_id dari sesi login yang tersimpan di HP
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('user_id');

      // Kalau belum login, hentikan loading
      if (userId == null) {
        setState(() { _isLoading = false; });
        return;
      }

      // 2. Tembak ke API CI4, kirim user_id
      Response response = await Dio().get(
        'http://localhost:8080/api/keranjang',
        queryParameters: {'user_id': userId},
      );

      setState(() {
        if (response.data['status'] == 'success') {
          _listKeranjang = response.data['data'];
          _hitungTotal(); // Panggil fungsi hitung total setelah data didapat
        }
        _isLoading = false;
      });
    } catch (e) {
      print("Error ambil data keranjang: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fungsi untuk menghitung total harga semua barang di keranjang
  void _hitungTotal() {
    double total = 0;
    for (var item in _listKeranjang) {
      // Pastikan tipe datanya angka saat dikali
      double harga = double.tryParse(item['harga_jual'].toString()) ?? 0;
      int jumlah = int.tryParse(item['jumlah'].toString()) ?? 1;
      total += (harga * jumlah);
    }
    setState(() {
      _totalBelanja = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Keranjang Saya',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _buildBody(),
      
      // Bagian Bawah: Total Harga & Tombol Checkout
      bottomNavigationBar: _listKeranjang.isNotEmpty && !_isLoading 
          ? _buildBottomCheckout() 
          : const SizedBox.shrink(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_listKeranjang.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Keranjang belanja kamu masih kosong.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _listKeranjang.length,
      itemBuilder: (context, index) {
        final item = _listKeranjang[index];
        return _buildKeranjangCard(item);
      },
    );
  }

  // Widget untuk desain 1 kotak barang di keranjang
  Widget _buildKeranjangCard(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Gambar Barang
          // Gambar Barang
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              // PERUBAHANNYA DI SINI
              image: item['gambar'] != null && item['gambar'].toString().trim().isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage('http://localhost:8080/api/image/${item['gambar']}'),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            // DAN DI SINI
            child: (item['gambar'] == null || item['gambar'].toString().trim().isEmpty)
                ? const Icon(Icons.image_not_supported, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 16),

          // Detail Barang (Nama & Harga)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['nama_barang'] ?? 'Tanpa Nama',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  'Rp ${item['harga_jual'] ?? 0}',
                  style: const TextStyle(
                    color: Color(0xFF0D6EFD),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Jumlah Barang (Qty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300)
            ),
            child: Text(
              'x ${item['jumlah'] ?? 1}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          )
        ],
      ),
    );
  }

  // Widget Bawah untuk Total Harga dan Checkout
  Widget _buildBottomCheckout() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Belanja',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  'Rp ${_totalBelanja.toInt()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 18, 
                    color: Colors.black87
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                // Nanti tambahkan logika checkout ke sini
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur Checkout belum tersedia')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF325A82), // Warna biru tema
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Checkout',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}