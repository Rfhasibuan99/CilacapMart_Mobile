import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'invoice_page.dart';
import 'main_layout.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> checkoutItems;
  final double totalSubtotal;

  const CheckoutPage({
    super.key,
    required this.checkoutItems,
    required this.totalSubtotal,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _penerimaController = TextEditingController();
  final TextEditingController _telpController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();

  String _metodePembayaran = 'QRIS';
  String _metodePengiriman = 'Grab';
  bool _isProcessing = false;

  final Color navyBlue = const Color(0xFF003366);
  final Color accentColor = const Color(0xFF0D6EFD);

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
  }

  @override
  void dispose() {
    _penerimaController.dispose();
    _telpController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  // Pre-fill profile info if logged in
  Future<void> _loadUserPreferences() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('user_id');
      if (userId != null) {
        Response response = await Dio().get('http://localhost:8080/api/akun/$userId');
        if (response.data['status'] == 1) {
          final data = response.data['data'];
          setState(() {
            _penerimaController.text = data['nama_pengguna'] != '-' ? data['nama_pengguna'] : '';
            _telpController.text = data['no_tlp'] != '-' ? data['no_tlp'] : '';
            _alamatController.text = data['alamat'] != '-' ? data['alamat'] : '';
          });
        }
      }
    } catch (e) {
      print("Error loading user preferences for checkout: $e");
    }
  }

  Future<void> _prosesPesanan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('user_id');

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan login terlebih dahulu.')),
        );
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      final payload = {
        'user_id': userId,
        'penerima': _penerimaController.text.trim(),
        'telp': _telpController.text.trim(),
        'alamat_lengkap': _alamatController.text.trim(),
        'metode_pembayaran': _metodePembayaran,
        'metode_pengiriman': _metodePengiriman,
        'items': widget.checkoutItems,
      };

      Response response = await Dio().post(
        'http://localhost:8080/api/pesanan/proses',
        data: payload,
      );

      if (response.data['status'] == true) {
        final idPesanan = response.data['data']['id_pesanan'];
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pesanan berhasil dibuat!'),
            backgroundColor: Colors.green,
          ),
        );

        // Redirect to InvoicePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => InvoicePage(idPesanan: idPesanan),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data['message'] ?? 'Gagal memproses pesanan.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error checkout: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menghubungi server. Silakan coba lagi.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double subtotal = widget.totalSubtotal;
    final double diskon = subtotal * 0.10;
    final double ongkir = 20000;
    final double totalHarga = subtotal - diskon + ongkir;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Konfirmasi Checkout',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Alamat Pengiriman Section
              _buildSectionTitle(Icons.location_on, 'Alamat Pengiriman'),
              const SizedBox(height: 8),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _penerimaController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Penerima',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama penerima tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _telpController,
                        decoration: const InputDecoration(
                          labelText: 'Nomor Telepon',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nomor telepon tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _alamatController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Alamat Lengkap',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.home),
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Alamat tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Rincian Barang Section
              _buildSectionTitle(Icons.shopping_bag, 'Produk Yang Dipesan'),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.checkoutItems.length,
                itemBuilder: (context, index) {
                  final item = widget.checkoutItems[index];
                  final String imgName = item['gambar'] ?? '';
                  final String imgUrl = imgName.isNotEmpty
                      ? 'http://localhost:8080/api/image/$imgName'
                      : '';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                              image: imgUrl.isNotEmpty
                                  ? DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.cover)
                                  : null,
                            ),
                            child: imgUrl.isEmpty
                                ? const Icon(Icons.image_not_supported, color: Colors.grey)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['nama_barang'] ?? 'Tanpa Nama',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Rp ${item['harga_jual']} x ${item['jumlah']}',
                                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Rp ${item['subtotal'].toInt()}',
                            style: TextStyle(fontWeight: FontWeight.bold, color: navyBlue),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(Icons.local_shipping, 'Kirim via'),
                        const SizedBox(height: 8),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            child: DropdownButton<String>(
                              value: _metodePengiriman,
                              isExpanded: true,
                              underline: const SizedBox(),
                              items: ['Grab', 'Gojek', 'JNE', 'Pos Indonesia']
                                  .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _metodePengiriman = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(Icons.payment, 'Pembayaran'),
                        const SizedBox(height: 8),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            child: DropdownButton<String>(
                              value: _metodePembayaran,
                              isExpanded: true,
                              underline: const SizedBox(),
                              items: ['QRIS', 'Transfer Mandiri', 'Transfer BCA', 'COD']
                                  .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _metodePembayaran = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildSectionTitle(Icons.receipt_long, 'Ringkasan Belanja'),
              const SizedBox(height: 8),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildSummaryRow('Total Harga', 'Rp ${subtotal.toInt()}'),
                      const SizedBox(height: 8),
                      _buildSummaryRow('Diskon Anggota (10%)', '- Rp ${diskon.toInt()}', isDiscount: true),
                      const SizedBox(height: 8),
                      _buildSummaryRow('Ongkos Kirim', 'Rp ${ongkir.toInt()}'),
                      const Divider(height: 24),
                      _buildSummaryRow('Total Pembayaran', 'Rp ${totalHarga.toInt()}', isTotal: true),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _prosesPesanan,
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
                      'Buat Pesanan Sekarang',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: navyBlue),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: navyBlue),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isDiscount = false, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black87 : Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
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
