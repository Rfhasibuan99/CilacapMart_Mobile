import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_layout.dart';
import 'detail_page.dart';
import 'invoice_page.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> _listBarang = [];
  bool _isLoadingBarang = true;
  List<dynamic> _listPesanan = [];
  bool _isLoadingPesanan = true;
  late TextEditingController _searchController;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _fetchDataBarang(); 
    _fetchDataPesanan();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchDataBarang({String? cari, String? kategori}) async {
    setState(() {
      _isLoadingBarang = true;
    });
    try {
      Map<String, dynamic> params = {};
      if (cari != null && cari.isNotEmpty) {
        params['cari'] = cari;
      }
      if (kategori != null && kategori.isNotEmpty) {
        params['kategori'] = kategori;
      }

      Response response = await Dio().get(
        'http://localhost:8080/api/barang',
        queryParameters: params,
      );
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
                _buildHeader(), 
                const SizedBox(height: 20),
                _buildSearchBar(),
                const SizedBox(height: 20),
                _buildBanner(),
                const SizedBox(height: 24),
                _buildPesananSection(), 
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
    );
  }

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
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined, size: 28),
              onPressed: () {
                LayoutUpdateNotification(2).dispatch(context);
              },
            ),
            GestureDetector(
              onTap: () {
                LayoutUpdateNotification(3).dispatch(context);
              },
              child: const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFFD9E2EC),
                child: Icon(Icons.person_outline, size: 20, color: Colors.black87),
              ),
            ),
          ],
        )
      ],
    );
  }

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
                  LayoutUpdateNotification(1).dispatch(context);
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
    return GestureDetector(
      onTap: () {
        final idPesanan = int.tryParse(pesanan['id_pesanan'].toString()) ?? 0;
        if (idPesanan > 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InvoicePage(idPesanan: idPesanan),
            ),
          );
        }
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
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
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF325A82), borderRadius: BorderRadius.circular(25)),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        textInputAction: TextInputAction.search,
        onChanged: (val) {
          setState(() {});
        },
        onSubmitted: (value) {
          setState(() {
            _selectedCategory = null;
          });
          _fetchDataBarang(cari: value);
        },
        decoration: InputDecoration(
          hintText: 'Cari barang...', hintStyle: const TextStyle(color: Colors.white70, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Colors.white), 
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                    });
                    _fetchDataBarang();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Kategori', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Icon(Icons.arrow_forward, size: 20),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: categories.map((cat) {
            final isSelected = _selectedCategory == cat['name'];
            return GestureDetector(
              onTap: () {
                if (isSelected) {
                  setState(() {
                    _selectedCategory = null;
                  });
                  _fetchDataBarang();
                } else {
                  setState(() {
                    _selectedCategory = cat['name'];
                    _searchController.clear();
                  });
                  _fetchDataBarang(kategori: cat['name']);
                }
              },
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundImage: NetworkImage(cat['img']!),
                      ),
                      if (isSelected)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withValues(alpha: 0.4),
                            ),
                            child: const Center(
                              child: Icon(Icons.check, color: Colors.white, size: 28),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cat['name']!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? const Color(0xFF0D6EFD) : Colors.black87,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPopularSection() => const Text('Populer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16));

  Widget _buildProductGrid() {
    if (_isLoadingBarang) return const Center(child: CircularProgressIndicator());
    if (_listBarang.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text('Belum ada barang yang tersedia.', style: TextStyle(color: Colors.grey)),
        ),
      );
    }
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.68,
      ),
      itemCount: _listBarang.length,
      itemBuilder: (context, index) {
        final barang = _listBarang[index];
        final String imgUrl = (barang['gambar'] != null && barang['gambar'].toString().trim().isNotEmpty)
            ? 'http://localhost:8080/api/image/${barang['gambar']}'
            : '';

        return Card(
          elevation: 3,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 6,
                child: imgUrl.isNotEmpty
                    ? Image.network(
                        imgUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey, size: 40)),
                        ),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: Colors.grey[100],
                            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey, size: 40)),
                      ),
              ),

              Expanded(
                flex: 4,
                child: Material(
                  color: Colors.white,
                  child: InkWell(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(barang: barang),
                        ),
                      );
                      if (result == true) {
                        _fetchDataBarang();
                      }
                    },
                    splashColor: const Color(0xFF003366).withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            barang['nama_barang'] ?? '...',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rp ${barang['harga_jual'] ?? 0}',
                            style: const TextStyle(
                              color: Color(0xFF0D6EFD),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Tap untuk detail →',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}