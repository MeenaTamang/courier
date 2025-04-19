

// import 'dart:convert';

// class ApiHelper{



// static void post(String url, Map<String, dynamic>? data) async {
//   try {
//     final response = await http.post(
//       Uri.parse(url),
//       headers: {
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode(data),
    
//     );

//     if (response.statusCode == 200) {
//       // Handle success
//       print('Response data: ${response.body}');
//     } else {
//       // Handle error
//       print('Error: ${response.statusCode}');
//     }
//   } catch (e) {
//     // Handle exception
//     print('Exception: $e');
//   }

//   // static void get(String url, Map<String, dynamic>? data){

//   // }
// }
// }