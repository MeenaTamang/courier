import 'dart:convert';

import 'package:courier/app/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EarningsView extends StatefulWidget {
  const EarningsView({super.key});

  @override
  State<EarningsView> createState() => _EarningsViewState();
}

class _EarningsViewState extends State<EarningsView> {
  double totalWages = 0.0;
  List<dynamic> earningHistory = [];
  bool isLoading = true;
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    fetchEarnings();
  }

  Future<void> fetchEarnings({bool isRefresh = false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print('Token missing. Redirecting...');
      return;
    }

    try {
      final calculateResponse = await http.get(
        Uri.parse('http://192.168.49.195:5183/api/earnings/calculate'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (calculateResponse.statusCode == 200) {
        final data = json.decode(calculateResponse.body);
        if (data['success']) {
          final dynamic wagesValue = data['data']['totalWages'];
          if (wagesValue != null) {
            totalWages = (wagesValue as num).toDouble();
          } else {
            totalWages = 0.0;
          }
        }
      }

      final historyResponse = await http.get(
        Uri.parse('http://192.168.49.195:5183/api/earnings/history'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (historyResponse.statusCode == 200) {
        final data = json.decode(historyResponse.body);
        if (data['success']) {
          earningHistory = data['data'];
        }
      }

      if (isRefresh) {
        _refreshController.refreshCompleted();
      }
    } catch (e) {
      print('Error fetching earnings: $e');
      if (isRefresh) {
        _refreshController.refreshFailed();
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MaterialTheme.blueColorScheme().secondary,
        title: const Text('Earnings'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/firstLayer.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SmartRefresher(
                  controller: _refreshController,
                  onRefresh: () => fetchEarnings(isRefresh: true),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 25.0, bottom: 50),
                    child: Column(
                      children: [
                        const Center(
                          child: Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                            size: 100,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Today's Earnings:",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "$totalWages rs",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: DataTable(
                            columnSpacing: 90,
                            headingRowColor: MaterialStateProperty.all(
                              MaterialTheme.blueColorScheme().secondaryContainer,
                            ),
                            columns: const [
                              DataColumn(
                                label: Text(
                                  'Date',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Amount',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ],
                            rows: earningHistory.map((item) {
                              return DataRow(cells: [
                                DataCell(Text(
                                  item['date'],
                                  style: const TextStyle(color: Colors.black),
                                )),
                                DataCell(Text(
                                  '${item['totalWage']} rs',
                                  style: const TextStyle(color: Colors.black),
                                )),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
