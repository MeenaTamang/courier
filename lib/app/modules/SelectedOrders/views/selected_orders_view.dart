import 'package:courier/app/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/selected_orders_controller.dart';

class SelectedOrdersView extends GetView<SelectedOrdersController> {
  const SelectedOrdersView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: MaterialTheme.blueColorScheme().primary,
      appBar: AppBar(
        backgroundColor: MaterialTheme.blueColorScheme().secondary,
        title: const Text('Selected Orders'),
        centerTitle: true,
      ),
      body:  Stack(
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
      // Content layer
      Container(
        child: ListView(
          children: [
            SizedBox(height: 15,),
            Padding(
              padding: const EdgeInsets.only(left: 17.0, right: 17.0, top: 5.0, bottom: 7.0),
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Icon(
                        Icons.local_shipping_outlined,
                        size: 50,
                        color: Colors.black,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
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
                            SizedBox(height: 4),
                            Row(
                              children: [
                                //trackingId
                                Text(
                                  'PKR-1234567',
                                  style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 11,
                                  ),
                                ),

                                SizedBox(width: 10),

                                // distanceInKm
                                Text(
                                  '~1.5 km',
                                  style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            
                            //weightInKg
                            SizedBox(height: 4),
                            Text(
                              'Weight: 10Kg',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                              ),
                            ),
                            
                            // urgencyLevel
                            SizedBox(height: 4),
                            Text(
                              'Priority: high',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 4),

                            //price
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
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Transform.scale(
                        scale: 2,
                        child: Checkbox(
                          value: false,
                          onChanged: (bool? newValue) {
                            // Handle checkbox state change
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
