// class Order {
//   final String deliveryAddress;
//   final String trackingId;
//   final String distanceInKm;
//   final String weightInKg;
//   final String UrgencyLevel;
//   final String wage;
//   bool isSelected;

//   Order({
//     required this.deliveryAddress,
//     required this.trackingId,
//     required this.distanceInKm,
//     required this.weightInKg,
//     required this.UrgencyLevel,
//     required this.wage,
//      this.isSelected = false, // Default to false
//   });

//   factory Order.fromJson(Map<String, dynamic> json) {
//     return Order(
//       trackingId: json['trackingId'] ?? '',
//       deliveryAddress: json['location'] ?? '',
//       distanceInKm: json['distance'] ?? '',
//       weightInKg: json['weight'] ?? '',
//       UrgencyLevel: (json['UrgencyLevel'] ?? '').toString().toLowerCase(), // normalize,
//       wage: json['wage'] ?? '',
//     );
//   }
// }


// // class Order {
// //   final String deliveryAddress;
// //   final String deliveryZone;

// //   Order({
// //     required this.deliveryAddress,
// //     required this.deliveryZone,
// //   });

// //   factory Order.fromJson(Map<String, dynamic> json) {
// //     return Order(
// //       deliveryAddress: json['deliveryAddress'],
// //       trackingId: json['trackingId'],
// //       distanceInKm: json['distanceInKm'],
// //       weightInKg: json['weightInKg'],
// //       UrgencyLevel: json['UrgencyLevel'],
// //     );
// //   }
// // }
