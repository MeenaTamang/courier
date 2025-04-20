// import 'dart:convert';

// import 'package:courier/app/data/models/order_model.dart';
// import 'package:http/http.dart' as http;


// class ApiService {

//   //orders
//   static const String _baseUrl = 'http://192.168.18.27:5183/api';

//   static Future<List<Order>> fetchPendingOrders() async {
//     final response = await http.get(Uri.parse('$_baseUrl/order/pendingorders'));

//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body);
//       return data.map((json) => Order.fromJson(json)).toList();
//     } else {
//       throw Exception('Failed to load pending orders');
//     }
//   }

// }

// static const String baseUrl = 'http://192.168.18.27:5183/api/workerdetails/getworkerdetails';

  /// Fetch worker details using userId
  // static Future<UserModel?> getWorkerDetails({required String userId}) async {
  //   final url = Uri.parse('$_baseUrl/workerdetails/getworkerdetails?userId=$userId');

  //   try {
  //     final response = await http.get(url);

  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       return UserModel.fromJson(data);
  //     } else {
  //       print('Error: ${response.statusCode}');
  //       return null;
  //     }
  //   } catch (e) {
  //     print('Exception in getWorkerDetails: $e');
  //     return null;
  //   }
  // }
