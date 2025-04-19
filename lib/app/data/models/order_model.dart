class Order {
  final String deliveryAddress;
  final String deliveryZone;

  Order({
    required this.deliveryAddress,
    required this.deliveryZone,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      deliveryAddress: json['deliveryAddress'],
      deliveryZone: json['deliveryZone'],
    );
  }
}
