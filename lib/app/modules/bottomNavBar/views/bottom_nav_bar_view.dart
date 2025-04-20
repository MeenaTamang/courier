import 'package:courier/app/core/theme/theme.dart';
import 'package:courier/app/modules/History/views/history_view.dart';
import 'package:courier/app/modules/Profile/views/profile_view.dart';
import 'package:courier/app/modules/SelectedOrders/views/selected_orders_view.dart';
import 'package:courier/app/modules/orders/views/orders_view.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

class BottomNavBarView extends StatefulWidget {
  final String userId; 
  const BottomNavBarView({super.key, required this.userId});

  @override
  _BottomNavBarViewState createState() => _BottomNavBarViewState();
}

class _BottomNavBarViewState extends State<BottomNavBarView> {
  int _selectedIndex = 0; // Track selected page index

  late List<Widget> _pages; // We use `late` because it depends on `widget.userId`

  @override
  void initState() {
    super.initState();

    _pages = [
      OrdersView(),
      SelectedOrdersView(),
      HistoryView(),
      ProfileView(userId: widget.userId), // Pass userId here
    ];
  }

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
        color: MaterialTheme.blueColorScheme().onSecondaryContainer,
        buttonBackgroundColor: MaterialTheme.blueColorScheme().secondary,
        backgroundColor: Colors.transparent,
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
