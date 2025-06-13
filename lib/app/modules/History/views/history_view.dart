import 'dart:convert';

import 'package:courier/app/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  bool isLoading = true;
  List<Order> historyOrders = [];
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    fetchHistoryOrders();
  }

  Future<void> fetchHistoryOrders({bool isRefresh = false}) async {
    const String url = 'http://192.168.49.195:5183/api/order/deliveredorders';
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception('Missing token. Please log in again.');
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (jsonResponse['success'] == true) {
        final List<dynamic> data = jsonResponse['data'];
        setState(() {
          historyOrders = data.map((json) => Order.fromJson(json)).toList();
          isLoading = false;
        });
        if (isRefresh) _refreshController.refreshCompleted();
      } else {
        throw Exception(jsonResponse['message'] ?? 'Unknown error');
      }
    } catch (e) {
      if (isRefresh) _refreshController.refreshFailed();
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching history: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MaterialTheme.blueColorScheme().secondary,
        title: const Text('History of Your Orders'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/firstLayer.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SmartRefresher(
                  controller: _refreshController,
                  onRefresh: () => fetchHistoryOrders(isRefresh: true),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 30),
                    itemCount: historyOrders.length,
                    itemBuilder: (context, index) {
                      final order = historyOrders[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 17.0, vertical: 8.0),
                        child: Container(
                          height: 130,
                          decoration: BoxDecoration(
                            color: MaterialTheme.blueColorScheme().secondaryContainer,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(255, 46, 49, 116).withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 9,
                                offset: const Offset(1, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(15),
                                child: Icon(Icons.local_shipping_outlined, size: 50),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on_outlined, size: 13),
                                          const SizedBox(width: 2),
                                          Expanded(
                                            child: Text(
                                              order.deliveryAddress,
                                              style: const TextStyle(
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(order.trackingId, style: const TextStyle(fontSize: 11)),
                                      const SizedBox(height: 4),
                                      Text('~${order.distanceInKm} km', style: const TextStyle(fontSize: 11)),
                                      Text(
                                        'Price: NPR ${order.wage}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}

class Order {
  final String deliveryAddress;
  final String trackingId;
  final double distanceInKm;
  final double wage;

  Order({
    required this.deliveryAddress,
    required this.trackingId,
    required this.distanceInKm,
    required this.wage,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      trackingId: json['trackingId'] ?? '',
      deliveryAddress: json['deliveryAddress'] ?? '',
      distanceInKm: (json['distanceInKm'] ?? 0).toDouble(),
      wage: (json['wage'] ?? 0).toDouble(),
    );
  }
}
