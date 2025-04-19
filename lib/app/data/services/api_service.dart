import 'dart:convert';

import 'package:courier/app/data/models/order_model.dart';
import 'package:http/http.dart' as http;

import '../models/user_model.dart';


class ApiService {
  final String baseUrl = 'http://192.168.1.148:5183/api';

  Future<UserModel> getUserData(String email) async {
    final response = await http.get(
      Uri.parse('$baseUrl/registration/$email'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data);
    } else {
      throw Exception('Failed to load user data');
    }
  }

  //orders
  Future<List<Order>> fetchOrders() async {
    final response = await http.get(
      Uri.parse('http://192.168.18.217:5183/api/order/allOrders'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((order) => Order.fromJson(order)).toList();
    } else {
      throw Exception('Failed to load orders');
    }
  }

}
