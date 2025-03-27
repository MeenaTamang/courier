import 'package:courier/app/core/theme/theme.dart';
import 'package:courier/app/modules/History/views/history_view.dart';
import 'package:courier/app/modules/Profile/views/profile_view.dart';
import 'package:courier/app/modules/SelectedOrders/views/selected_orders_view.dart';
import 'package:courier/app/modules/orders/views/orders_view.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

// import '../history/views/history_view.dart';
// import '../orders/views/orders_view.dart';
// import '../profile/views/profile_view.dart';
// import '../selected_orders/views/selected_orders_view.dart';

class BottomNavBarView extends StatefulWidget {
  const BottomNavBarView({super.key});

  @override
  _BottomNavBarViewState createState() => _BottomNavBarViewState();
}

class _BottomNavBarViewState extends State<BottomNavBarView> {
  int _selectedIndex = 0; // Track selected page index

  final List<Widget> _pages = [
    OrdersView(),
    SelectedOrdersView(),
    HistoryView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages, // Display the selected page
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        items: const <Widget>[
          Icon(Icons.local_shipping_outlined, size: 30), // Orders Page
          Icon(Icons.list_alt_outlined, size: 30), // Selected Orders
          Icon(Icons.history, size: 30), // History Page
          Icon(Icons.perm_identity, size: 30), // Profile Page
        ],
        color: MaterialTheme.blueColorScheme().secondary,
        buttonBackgroundColor: MaterialTheme.blueColorScheme().surfaceTint,
        backgroundColor: MaterialTheme.blueColorScheme().primary,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 600),
        onTap: (index) {
          setState(() {
            _selectedIndex = index; // Switch pages on tap
          });
        },
      ),
    );
  }
}
