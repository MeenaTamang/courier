import 'dart:convert';

import 'package:courier/app/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OrdersView extends StatefulWidget {
  const OrdersView({super.key});

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> {
  bool isLoading = true;
  List<Order> orders = [];

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

Future<void> fetchOrders() async {
  const String url = 'http://192.168.49.16:5183/api/order/pendingorders';
  try {
    final response = await http.get(Uri.parse(url));
    print('status code is ${response.statusCode}');
    print('response is ${response.body}');

    // if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      print('response ${jsonResponse}');

      final List<dynamic> data = jsonResponse['data']; // <-- Correct key here

      print('json array ${data}');

      setState(() {
        orders = data.map((json) => Order.fromJson(json)).toList();
        isLoading = false;
      });
    // } else {
      // throw Exception('Failed to load orders');
    // }
  } catch (e) {
    setState(() => isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error fetching orders: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MaterialTheme.blueColorScheme().secondary,
        title: const Text('Orders'),
        centerTitle: true,
      ),
      body:
        Stack(
          children: [
            // Background image layer
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/firstLayer.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: orders.length,
              padding: const EdgeInsets.only(bottom: 80),
              itemBuilder: (context, index) {
                final order = orders[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 17.0, vertical: 8.0),
                  child: Container(
                    height: 120,
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
                                    const Icon(Icons.location_on_outlined, size: 15),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(order.deliveryAddress,
                                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(order.trackingId, style: const TextStyle(fontSize: 11)),
                                    const SizedBox(width: 10),
                                    // Text(order.distanceInKm.toString(), style: const TextStyle(fontSize: 11)),

                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text('~${order.distanceInKm} Km', style: const TextStyle(fontSize: 12)),
                                Text('Weight: ${order.weightInKg} Kg', style: const TextStyle(fontSize: 12)),
                                Text('Priority: ${order.urgencyLevel}', style: const TextStyle(fontSize: 12)),
                                Text('Price: ${order.wage}',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
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
            Positioned(
              bottom: 30,
              left: 290,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  // Add your button action here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: MaterialTheme.blueColorScheme().onSecondaryContainer,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Confirm',
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

// Standalone Order model
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
      distanceInKm: json['distanceInKm'] ?? 0,
      weightInKg: json['weightInKg'] ?? 0.0,
      urgencyLevel: (json['urgencyLevel'] ?? ''),
      wage: json['wage'] ?? 0.0,
    );
  }
}
