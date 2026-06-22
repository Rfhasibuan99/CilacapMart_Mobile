import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'checkout_page.dart';

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

  Future<void> _updateQty(int idKeranjang, int newQty) async {
    if (newQty <= 0) {
      _hapusItem(idKeranjang);
      return;
    }

    try {
      Response response = await Dio().post(
        'http://localhost:8080/api/keranjang/ubah_qty',
        data: {
          'id_keranjang': idKeranjang,
          'jumlah': newQty,
        },
      );
      if (response.data['status'] == true) {
        _fetchDataKeranjang();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data['message'] ?? 'Gagal mengubah jumlah barang.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error update qty: $e");
    }
  }

  Future<void> _hapusItem(int idKeranjang) async {
    try {
      Response response = await Dio().post(
        'http://localhost:8080/api/keranjang/hapus',
        data: {
          'id_keranjang': idKeranjang,
        },
      );
      if (response.data['status'] == true) {
        _fetchDataKeranjang();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data['message'] ?? 'Gagal menghapus barang.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error delete cart item: $e");
    }
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
    final int idKeranjang = int.tryParse(item['id_keranjang'].toString()) ?? 0;
    final int jumlah = int.tryParse(item['jumlah'].toString()) ?? 1;

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
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              image: item['gambar'] != null && item['gambar'].toString().trim().isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage('http://localhost:8080/api/image/${item['gambar']}'),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
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

          // Controls (Minus, Qty, Plus, Delete)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                onPressed: () => _hapusItem(idKeranjang),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _updateQty(idKeranjang, jumlah - 1),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.remove, size: 16, color: Colors.black87),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      '$jumlah',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _updateQty(idKeranjang, jumlah + 1),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, size: 16, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

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
                final List<Map<String, dynamic>> checkoutItems = [];
                for (var item in _listKeranjang) {
                  final double harga = double.tryParse(item['harga_jual'].toString()) ?? 0;
                  final int jumlah = int.tryParse(item['jumlah'].toString()) ?? 1;
                  checkoutItems.add({
                    'id_barang': item['id_barang'],
                    'id_keranjang': item['id_keranjang'],
                    'nama_barang': item['nama_barang'],
                    'harga_jual': harga,
                    'jumlah': jumlah,
                    'subtotal': harga * jumlah,
                    'gambar': item['gambar'],
                  });
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CheckoutPage(
                      checkoutItems: checkoutItems,
                      totalSubtotal: _totalBelanja,
                    ),
                  ),
                ).then((_) {
                  _fetchDataKeranjang(); // Refresh cart when returning
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF325A82),
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