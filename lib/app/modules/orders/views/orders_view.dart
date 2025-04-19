import 'package:courier/app/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/orders_controller.dart';

class OrdersView extends GetView<OrdersController> {
  const OrdersView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: MaterialTheme.blueColorScheme().primary,
      appBar: AppBar(
        backgroundColor: MaterialTheme.blueColorScheme().secondary,
        title: const Text('Orders'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/firstLayer.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: controller.orderList.length,
            itemBuilder: (context, index) {
              final order = controller.orderList[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 17.0, vertical: 7.0),
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: MaterialTheme.blueColorScheme().secondaryContainer,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 46, 49, 116).withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 9,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(15),
                        child: Icon(
                          Icons.local_shipping_outlined,
                          size: 40,
                          color: Colors.black,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 15,
                                    color: Colors.black,
                                  ),
                                  const SizedBox(width: 1),
                                  Text(
                                    '${order.deliveryAddress}, ',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    order.deliveryZone,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'PKR-123123 ~ 1.5 km',
                                // 'PKR-${order.orderCode ?? 'XXXXXXX'} ~ ${order.distance ?? '1.5 km'}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'NPR 100',
                                // 'Price: NPR ${order.price ?? '100'}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Transform.scale(
                          scale: 2,
                          child: Checkbox(
                            value: false,
                            onChanged: (bool? newValue) {
                              // Handle checkbox state
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      )
    );
  }
}
