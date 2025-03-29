import 'package:courier/app/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/orders_controller.dart';

class OrdersView extends GetView<OrdersController> {
  const OrdersView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MaterialTheme.blueColorScheme().primary,
      appBar: AppBar(
        backgroundColor: MaterialTheme.blueColorScheme().secondary,
        title: const Text('Orders'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          SizedBox(height: 15,),
          
          Padding(
            padding: const EdgeInsets.only(left: 17.0, right: 17.0, top: 5.0, bottom: 7.0),
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: MaterialTheme.blueColorScheme().secondaryContainer,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 46, 49, 116).withOpacity(0.3), // Shadow color with opacity
                spreadRadius: 1, // How far the shadow will spread
                blurRadius: 9, // The blur effect for the shadow
                offset: Offset(0, 2), // The offset of the shadow (x, y)
              ),
            ],
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(padding: const EdgeInsets.all(15),
              child: Icon(
                Icons.local_shipping_outlined,
                size: 40,
                color: Colors.black,
                ),
              ),
            Expanded(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    //Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: Colors.black,
                      ),
                      SizedBox(width: 1),
                      Text(
                        
                        'Jhamshikhel, Lalitpur',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4,),
                  //Distance
                  Text(
                    'PKR-1234567 ~ 1.5 km',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                    ),
                  ),
                  SizedBox(height: 4,),
                  //Price
                  Text(
                    'Price: NPR 100',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
              ),
            ),

          //checkbox
          Padding(
            padding: const EdgeInsets.all(20),
            child: Transform.scale(
              scale: 2, // Adjust the scale to increase the size of the checkbox
              child: Checkbox(
                value: true, // Change to dynamic value (e.g., controller.value)
                onChanged: (bool? newvalue) {
                  //handle checkbox state change
                },
              ),
            ),
          ),
          ],
          ),
          ),
          ),

        ],
      )
    );
  }
}
