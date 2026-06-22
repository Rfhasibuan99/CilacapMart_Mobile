import 'package:flutter/material.dart';
import 'DashboardScreen.dart';
import 'profile_page.dart';
import 'PesananScreen.dart';
import 'KeranjangScreen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final Color navyBlue = const Color(0xFF003366);
  final Color lightBlue = const Color(0xFFADD8E6);
  final Color backgroundColor = const Color(0xFFE8EFF7);

  final List<Widget> _pages = [
    const DashboardScreen(),
    const PesananScreen(),
    const KeranjangScreen(),
    const ProfilePage(),
  ];

  void _changePage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<LayoutUpdateNotification>(
      onNotification: (notification) {
        _changePage(notification.targetIndex);
        return true;
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: _currentIndex == 0
            ? AppBar(
                backgroundColor: navyBlue,
                elevation: 0,
                centerTitle: false,
                iconTheme: const IconThemeData(color: Colors.white),
                title: InkWell(
                  onTap: () => _changePage(0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.storefront,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Cilacap Mart",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none,
                      color: Colors.white,
                    ),
                    tooltip: 'Notifikasi',
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.help_outline, color: Colors.white),
                    tooltip: 'Bantuan',
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                ],
              )
            : null,
      
        body: IndexedStack(index: _currentIndex, children: _pages),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: navyBlue,
          selectedItemColor: lightBlue,
          unselectedItemColor: Colors.white.withOpacity(0.65),
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          onTap: _changePage,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              label: 'Pesanan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              label: 'Keranjang',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_outlined),
              label: 'Akun',
            ),
          ],
        ),
      ),
    );
  }
}

class LayoutUpdateNotification extends Notification {
  final int targetIndex;
  LayoutUpdateNotification(this.targetIndex);
}
