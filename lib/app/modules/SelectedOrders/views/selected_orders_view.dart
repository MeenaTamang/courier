import 'dart:convert';

import 'package:courier/app/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectedOrdersView extends StatefulWidget {
  const SelectedOrdersView({super.key});

  @override
  State<SelectedOrdersView> createState() => _SelectedOrdersViewState();
}

class _SelectedOrdersViewState extends State<SelectedOrdersView> {
  bool isLoading = true;
  List<Order> orders = [];
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    fetchSelectedOrders();
  }

  Future<void> fetchSelectedOrders({bool isRefresh = false}) async {
    const String url = 'http://192.168.49.195:5183/api/order/inprogressorders';
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
          orders = data.map((json) => Order.fromJson(json)).toList();
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
        SnackBar(content: Text('Error fetching orders: $e')),
      );
    }
  }

  Future<void> completedOrders({
    required int workerId,
    required int workerOrderId,
    required List orderId,
  }) async {
    const String url = 'http://192.168.49.195:5183/api/order/savecompletedorders';
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception('Missing token. Please log in again.');
      }

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final Map<String, dynamic> body = {
        "workerId": workerId,
        "orderId": List<int>.from(orderId),
      };

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true && jsonResponse['data'] is List) {
        final List<dynamic> data = jsonResponse['data'];
        setState(() {
          orders = data.map((json) => Order.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception(jsonResponse['message'] ?? 'Order confirmation failed');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MaterialTheme.blueColorScheme().secondary,
        title: const Text('Selected Orders'),
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
                  onRefresh: () => fetchSelectedOrders(isRefresh: true),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 17.0, vertical: 8.0),
                        child: Container(
                          height: 140,
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
                                          const Icon(Icons.location_on_outlined, size: 10),
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
                                      Row(
                                        children: [
                                          Text(order.trackingId, style: const TextStyle(fontSize: 11)),
                                          const SizedBox(width: 10),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text('~${order.distanceInKm} km', style: const TextStyle(fontSize: 11)),
                                      Text('Weight: ${order.weightInKg} Kg', style: const TextStyle(fontSize: 12)),
                                      Text('Priority: ${order.urgencyLevel}', style: const TextStyle(fontSize: 12)),
                                      Text('Price: NPR ${order.wage}',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(15),
                                child: Transform.scale(
                                  scale: 2,
                                  child: Checkbox(
                                    value: order.isSelected,
                                    onChanged: (bool? newValue) {
                                      setState(() {
                                        order.isSelected = newValue ?? false;
                                      });
                                    },
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
          Positioned(
            bottom: 30,
            left: 220,
            right: 20,
            child: ElevatedButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                int workerId = prefs.getInt('workerId') ?? 0;

                List<int> selectedOrderIds = orders
                    .where((order) => order.isSelected)
                    .map((order) => int.tryParse(order.trackingId.split('-').first) ?? 0)
                    .toList();

                if (selectedOrderIds.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select at least one order.')),
                  );
                  return;
                }

                await completedOrders(
                  workerId: workerId,
                  workerOrderId: 0,
                  orderId: selectedOrderIds,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MaterialTheme.blueColorScheme().onSecondaryContainer,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Completed',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
  final double weightInKg;
  final String urgencyLevel;
  final double wage;
  bool isSelected;

  Order({
    required this.deliveryAddress,
    required this.trackingId,
    required this.distanceInKm,
    required this.weightInKg,
    required this.urgencyLevel,
    required this.wage,
    this.isSelected = false,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      trackingId: json['trackingId'] ?? '',
      deliveryAddress: json['deliveryAddress'] ?? '',
      distanceInKm: (json['distanceInKm'] ?? 0).toDouble(),
      weightInKg: (json['weightInKg'] ?? 0).toDouble(),
      urgencyLevel: json['urgencyLevel'] ?? '',
      wage: (json['wage'] ?? 0).toDouble(),
    );
  }
}
