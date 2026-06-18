import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import halaman-halaman yang dibutuhkan
import 'KeranjangScreen.dart'; 
import 'PesananScreen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  
  List<dynamic> _listBarang = [];
  bool _isLoadingBarang = true;
  List<dynamic> _listPesanan = [];
  bool _isLoadingPesanan = true;

  @override
  void initState() {
    super.initState();
    _fetchDataBarang(); 
    _fetchDataPesanan();
  }

  // --- AMBIL DATA BARANG ---
  Future<void> _fetchDataBarang() async {
    try {
      Response response = await Dio().get('http://localhost:8080/api/barang');
      setState(() {
        if (response.data is List) {
           _listBarang = response.data;
        } else if (response.data['data'] != null) {
           _listBarang = response.data['data'];
        }
        _isLoadingBarang = false;
      });
    } catch (e) {
      print("Error ambil data barang: $e");
      setState(() { _isLoadingBarang = false; });
    }
  }

  // --- AMBIL DATA PESANAN (UNTUK SECTION HORIZONTAL) ---
  Future<void> _fetchDataPesanan() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('user_id');

      if (userId == null) return;

      Response response = await Dio().get(
        'http://localhost:8080/api/pesanan',
        queryParameters: {'user_id': userId},
      );

      setState(() {
        if (response.data['status'] == 'success' || response.data is List) {
          _listPesanan = response.data is List ? response.data : response.data['data'];
        }
        _isLoadingPesanan = false;
      });
    } catch (e) {
      print("Error pesanan dashboard: $e");
      setState(() { _isLoadingPesanan = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), 
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildHeader(), // <-- DI SINI TOMBOL KERANJANGNYA
                const SizedBox(height: 20),
                _buildSearchBar(),
                const SizedBox(height: 20),
                _buildBanner(),
                const SizedBox(height: 24),
                _buildPesananSection(), // Section Pesanan Aktif
                _buildCategorySection(),
                const SizedBox(height: 24),
                _buildPopularSection(),
                const SizedBox(height: 16),
                _buildProductGrid(), 
                const SizedBox(height: 20), 
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // --- WIDGET HEADER (DENGAN NAVIGASI KE KERANJANG) ---
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: const [
            Icon(Icons.location_on_outlined, size: 24),
            SizedBox(width: 4),
            Text(
              'Cilacap, Jawa Tengah',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Icon(Icons.keyboard_arrow_down, size: 20),
          ],
        ),
        Row(
          children: [
            // TOMBOL KE KERANJANG
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined, size: 28),
              onPressed: () {
                // PINDAH KE HALAMAN KERANJANG
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const KeranjangScreen()),
                );
              },
            ),
            const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFFD9E2EC),
              child: Icon(Icons.person_outline, size: 20, color: Colors.black87),
            ),
          ],
        )
      ],
    );
  }

  // --- SECTION PESANAN AKTIF ---
  Widget _buildPesananSection() {
    if (_isLoadingPesanan || _listPesanan.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Pesanan Aktif', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              GestureDetector(
                onTap: () {
                  // PINDAH KE RIWAYAT PESANAN LENGKAP
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PesananScreen()),
                  );
                },
                child: const Icon(Icons.arrow_forward, size: 20, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _listPesanan.length,
              itemBuilder: (context, index) {
                final pesanan = _listPesanan[index];
                return _buildMiniPesananCard(pesanan);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniPesananCard(dynamic pesanan) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200], borderRadius: BorderRadius.circular(8),
                image: pesanan['gambar'] != null && pesanan['gambar'] != ''
                    ? DecorationImage(
                        image: NetworkImage('http://localhost:8080/api/image/${pesanan['gambar']}'),
                        fit: BoxFit.cover)
                    : null,
              ),
              child: (pesanan['gambar'] == null || pesanan['gambar'] == '')
                  ? const Icon(Icons.inventory_2, color: Colors.grey, size: 20) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(pesanan['kode_pesanan'] ?? 'ORD-XXX', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  Text('Rp ${pesanan['total_harga'] ?? 0}', style: const TextStyle(color: Color(0xFF0D6EFD), fontWeight: FontWeight.bold, fontSize: 12)),
                  Text(pesanan['status'] ?? 'Pending', style: const TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET LAINNYA (SAMA SEPERTI SEBELUMNYA) ---
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF325A82), borderRadius: BorderRadius.circular(25)),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Cari', hintStyle: TextStyle(color: Colors.white70, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.white), border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      height: 150, width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=800&q=80'),
          fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.black38, BlendMode.darken),
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Cari Info Terbaru Disini !', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Widget _buildCategorySection() {
    final categories = [
      {'name': 'Makanan', 'img': 'https://images.unsplash.com/photo-1550461716-dbf266b2a8a7?w=200&q=80'},
      {'name': 'Minuman', 'img': 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=200&q=80'},
      {'name': 'Kerajinan', 'img': 'https://images.unsplash.com/photo-1606760227091-3dd870d97f1d?w=200&q=80'},
      {'name': 'Busana', 'img': 'https://images.unsplash.com/photo-1512436991641-6745cdb1723f?w=200&q=80'},
    ];
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [Text('Kategori', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Icon(Icons.arrow_forward, size: 20)]),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: categories.map((cat) => Column(children: [CircleAvatar(radius: 35, backgroundImage: NetworkImage(cat['img']!)), const SizedBox(height: 8), Text(cat['name']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))])).toList()),
      ],
    );
  }

  Widget _buildPopularSection() => const Text('Populer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16));

  Widget _buildProductGrid() {
    if (_isLoadingBarang) return const Center(child: CircularProgressIndicator());
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(), shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.75),
      itemCount: _listBarang.length,
      itemBuilder: (context, index) {
        final barang = _listBarang[index];
        return Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Container(decoration: BoxDecoration(borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)), color: Colors.grey[200], image: barang['gambar'] != null ? DecorationImage(image: NetworkImage('http://localhost:8080/api/image/${barang['gambar']}'), fit: BoxFit.cover) : null))),
            Padding(padding: const EdgeInsets.all(8.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(barang['nama_barang'] ?? '...', style: const TextStyle(fontWeight: FontWeight.bold)), Text('Rp ${barang['harga_jual'] ?? 0}', style: const TextStyle(color: Color(0xFF0D6EFD), fontWeight: FontWeight.bold))])),
          ]),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() => _selectedIndex = index);
        if (index == 2) { // Contoh: Menu Inventory bisa diarahkan ke Pesanan
           Navigator.push(context, MaterialPageRoute(builder: (context) => const PesananScreen()));
        }
      },
      type: BottomNavigationBarType.fixed, selectedItemColor: const Color(0xFF1B4965),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
      ],
    );
  }
}