import 'dart:async';
import 'dart:convert';
import 'package:courier/app/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrdersView extends StatefulWidget {
  const OrdersView({super.key});

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> {
  // ── EXISTING state variables ───────────────────────────────────────────────
  bool isLoading = true;
  List<Order> orders = [];
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  // ── MAP state variables ────────────────────────────────────────────────────
  final MapController _mapController = MapController();
  bool _hasRoute = false;
  bool isTracking = false;
  Timer? _locationTimer;

  // Hub / worker / stop data
  LatLng? _hubLatLng;
  LatLng? _workerLatLng;
  List<_StopInfo> _stops = [];

  // ── Track completed order IDs so marker stays green after refresh ──────────
  final Set<String> _completedOrderIds = {};

  // ── Track whether ALL stops are done so hub turns green ───────────────────
  bool get _allStopsCompleted =>
      _stops.isNotEmpty &&
      _stops.every((s) => _completedOrderIds.contains(s.orderId));

  static const String baseUrl =
      'https://barley-chimp-girdle.ngrok-free.dev';

  @override
  void initState() {
    super.initState();
    fetchOrders();
    fetchRoute();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  // ── Logout helper ──────────────────────────────────────────────────────────
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  // ── Refresh both orders and route WITHOUT wiping the map ──────────────────
  Future<void> _refreshAll() async {
    await Future.wait([fetchOrders(), fetchRoute()]);
  }

  // ── EXISTING METHOD — unchanged ────────────────────────────────────────────
  Future<void> fetchOrders({bool isRefresh = false}) async {
    const String url = '$baseUrl/api/order/pendingorders';
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception('Missing token. Please log in again.');
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'Meena',
        },
      );

      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (jsonResponse['success'] == true) {
        final List<dynamic> data = jsonResponse['data'];
        setState(() {
          orders = data.map((json) => Order.fromJson(json)).toList();
          isLoading = false;
        });
        if (isRefresh) _refreshController.refreshCompleted();
      } else {
        throw Exception(jsonResponse['message'] ?? 'Unknown error');
      }
    } catch (e) {
      if (isRefresh) _refreshController.refreshFailed();
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching orders: $e')),
        );
      }
    }
  }

  // ── EXISTING METHOD — unchanged ────────────────────────────────────────────
  Future<void> confirmOrders({
    required int workerId,
    required int workerOrderId,
    required List orderId,
  }) async {
    const String url = '$baseUrl/api/order/saveselectedorders';
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception('Missing token. Please log in again.');
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'Meena',
      };

      final body = {
        "workerId": workerId,
        "orderId": List<int>.from(orderId),
      };

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Orders confirmed!')),
          );
        }
        fetchOrders();
      } else {
        throw Exception(
            jsonResponse['message'] ?? 'Order confirmation failed');
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  // ── EXISTING METHOD — unchanged ────────────────────────────────────────────
  Future<int?> getWorkerIdFromToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) return null;
    try {
      final decoded = JwtDecoder.decode(token);
      final workerIdStr = decoded['workerId'];
      return int.tryParse(workerIdStr.toString());
    } catch (e) {
      print("Token decoding error: $e");
      return null;
    }
  }

  // ── fetch optimized route from backend ────────────────────────────────────
  Future<void> fetchRoute() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) return;

      final response = await http.get(
        Uri.parse('$baseUrl/api/order/assignedroute'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'Meena',
        },
      );

      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] != true) return;

      final data = jsonResponse['data'];

      final List<dynamic> pointsRaw = data['polylinePoints'] ?? [];
      if (pointsRaw.isEmpty) return;

      final hubLatLng = LatLng(
          (data['hubLat'] as num).toDouble(),
          (data['hubLng'] as num).toDouble());

      final List<dynamic> stops = data['stops'] ?? [];
      final List<_StopInfo> freshStops = stops
          .map((s) => _StopInfo(
                orderId: s['orderId'].toString(),
                position: LatLng(
                    (s['lat'] as num).toDouble(),
                    (s['lng'] as num).toDouble()),
                sequence: s['sequenceNumber'].toString(),
                address: s['deliveryAddress'] ?? '',
              ))
          .toList();

      // ── Detect newly completed stops (were in old list, gone from fresh list)
      // and mark them completed — but KEEP them in _stops so their marker stays.
      if (_stops.isNotEmpty) {
        final freshIds = freshStops.map((s) => s.orderId).toSet();
        for (final old in _stops) {
          if (!freshIds.contains(old.orderId)) {
            _completedOrderIds.add(old.orderId);
          }
        }
      }

      // ── Build merged stop list:
      // Start with fresh (pending) stops, then append any OLD stops that are
      // now completed so their green markers remain on the map.
      final freshIds = freshStops.map((s) => s.orderId).toSet();
      final completedStops = _stops
          .where((s) =>
              _completedOrderIds.contains(s.orderId) &&
              !freshIds.contains(s.orderId))
          .toList();

      final mergedStops = [...freshStops, ...completedStops];

      if (!mounted) return;
      setState(() {
        _hasRoute = true;
        _hubLatLng = hubLatLng;
        _stops = mergedStops; // ← contains BOTH pending + completed stops
        _workerLatLng = _workerLatLng;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) => _fitBounds());
    } catch (e) {
      print('Route fetch error: $e');
    }
  }

  // ── Mark a stop as completed manually (tap the marker) ────────────────────
  void _markStopCompleted(String orderId) {
    setState(() => _completedOrderIds.add(orderId));
  }

  // ── live location tracking ─────────────────────────────────────────────────
  Future<void> startTracking() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')));
      }
      return;
    }

    setState(() => isTracking = true);

    _locationTimer =
        Timer.periodic(const Duration(seconds: 15), (_) async {
      try {
        final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        final pos = LatLng(position.latitude, position.longitude);

        if (!mounted) return;
        setState(() => _workerLatLng = pos);

        _mapController.move(pos, _mapController.camera.zoom);

        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        await http.put(
          Uri.parse('$baseUrl/api/order/updatelocation'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'ngrok-skip-browser-warning': 'Meena',
          },
          body: jsonEncode({
            'lat': position.latitude,
            'lng': position.longitude,
          }),
        );
      } catch (e) {
        print('Location update error: $e');
      }
    });
  }

  void stopTracking() {
    _locationTimer?.cancel();
    setState(() => isTracking = false);
  }

  // ── fit map bounds to all markers ─────────────────────────────────────────
  void _fitBounds() {
    final allPoints = [
      if (_hubLatLng != null) _hubLatLng!,
      ..._stops.map((s) => s.position),
      if (_workerLatLng != null) _workerLatLng!,
    ];
    if (allPoints.isEmpty) return;

    final lats = allPoints.map((p) => p.latitude);
    final lngs = allPoints.map((p) => p.longitude);
    final minLat = lats.reduce((a, b) => a < b ? a : b);
    final maxLat = lats.reduce((a, b) => a > b ? a : b);
    final minLng = lngs.reduce((a, b) => a < b ? a : b);
    final maxLng = lngs.reduce((a, b) => a > b ? a : b);

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds(
          LatLng(minLat - 0.01, minLng - 0.01),
          LatLng(maxLat + 0.01, maxLng + 0.01),
        ),
        padding: const EdgeInsets.all(60),
      ),
    );
  }

  // ── Build markers ──────────────────────────────────────────────────────────
  List<Marker> _buildMarkers() {
    final List<Marker> result = [];

    // ── Hub marker — blue normally, green when ALL stops completed ───────────
    if (_hubLatLng != null) {
      final bool hubDone = _allStopsCompleted;
      result.add(Marker(
        point: _hubLatLng!,
        width: 48,
        height: 48,
        child: Tooltip(
          message: hubDone
              ? '✅ All deliveries complete — return to hub'
              : '📦 Hub — Pick up here first',
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            decoration: BoxDecoration(
              color: hubDone
                  ? Colors.green.withOpacity(0.15)
                  : Colors.blue.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              hubDone ? Icons.warehouse : Icons.warehouse_outlined,
              color: hubDone ? Colors.green : Colors.blue,
              size: 36,
            ),
          ),
        ),
      ));
    }

    // ── Stop markers — red normally, green when completed ────────────────────
    for (final stop in _stops) {
      final bool done = _completedOrderIds.contains(stop.orderId);
      result.add(Marker(
        point: stop.position,
        width: 44,
        height: 56,
        child: GestureDetector(
          onTap: () => _showCompleteDialog(stop),
          child: Tooltip(
            message: done
                ? '✅ Stop ${stop.sequence} delivered\n${stop.address}'
                : 'Stop ${stop.sequence}\n${stop.address}',
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.location_pin,
                  // Green when done, red when pending
                  color: done ? Colors.green : Colors.red,
                  size: 40,
                ),
                Positioned(
                  top: 4,
                  child: Text(
                    stop.sequence,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                // Small tick badge when completed
                if (done)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check,
                          color: Colors.white, size: 11),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ));
    }

    // ── Worker / you-are-here marker ─────────────────────────────────────────
    if (_workerLatLng != null) {
      result.add(Marker(
        point: _workerLatLng!,
        width: 40,
        height: 40,
        child: const Tooltip(
          message: '🚴 You are here',
          child: Icon(Icons.directions_bike, color: Colors.green, size: 36),
        ),
      ));
    }

    return result;
  }

  // ── Confirm-delivery dialog shown when tapping a stop marker ──────────────
  void _showCompleteDialog(_StopInfo stop) {
    final bool alreadyDone = _completedOrderIds.contains(stop.orderId);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(alreadyDone
            ? 'Stop ${stop.sequence} — Delivered ✅'
            : 'Stop ${stop.sequence}'),
        content: Text(
          alreadyDone
              ? 'This delivery is already marked as complete.'
              : '${stop.address}\n\nMark this stop as delivered?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          if (!alreadyDone)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.check),
              label: const Text('Mark Delivered'),
              onPressed: () {
                Navigator.pop(ctx);
                _markStopCompleted(stop.orderId);
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) await _logout();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: MaterialTheme.blueColorScheme().secondary,
          title: const Text('Orders Route'),
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: _refreshAll,
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : _hasRoute
                // ── MAP view ───────────────────────────────────────────────
                ? Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _hubLatLng ?? const LatLng(0, 0),
                          initialZoom: 13,
                          minZoom: 3,
                          maxZoom: 19,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.all,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.courier',
                          ),
                          MarkerLayer(markers: _buildMarkers()),
                        ],
                      ),

                      // ── Progress chip — top center ─────────────────────
                      Positioned(
                        top: 12,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              _allStopsCompleted
                                  ? '🎉 All ${_stops.length} deliveries complete!'
                                  : '${_completedOrderIds.length} / ${_stops.length} delivered',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _allStopsCompleted
                                    ? Colors.green.shade700
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ── Reset zoom ────────────────────────────────────
                      Positioned(
                        bottom: 20,
                        right: 16,
                        child: FloatingActionButton.small(
                          heroTag: 'fitBounds',
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          tooltip: 'Reset to full route',
                          onPressed: _fitBounds,
                          child: const Icon(Icons.fit_screen),
                        ),
                      ),

                      // ── Zoom in / out ─────────────────────────────────
                      Positioned(
                        bottom: 80,
                        right: 16,
                        child: Column(
                          children: [
                            FloatingActionButton.small(
                              heroTag: 'zoomIn',
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black87,
                              tooltip: 'Zoom in',
                              onPressed: () => _mapController.move(
                                _mapController.camera.center,
                                _mapController.camera.zoom + 1,
                              ),
                              child: const Icon(Icons.add),
                            ),
                            const SizedBox(height: 8),
                            FloatingActionButton.small(
                              heroTag: 'zoomOut',
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black87,
                              tooltip: 'Zoom out',
                              onPressed: () => _mapController.move(
                                _mapController.camera.center,
                                _mapController.camera.zoom - 1,
                              ),
                              child: const Icon(Icons.remove),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )

                // ── ORDER LIST view ────────────────────────────────────────
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
                        onRefresh: () => fetchOrders(isRefresh: true),
                        child: orders.isEmpty
                            ? const Center(
                                child: Text(
                                  'No pending orders',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                              )
                            : ListView.builder(
                                itemCount: orders.length,
                                padding: const EdgeInsets.only(bottom: 90),
                                itemBuilder: (context, index) {
                                  final order = orders[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 17.0, vertical: 8.0),
                                    child: IntrinsicHeight(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: MaterialTheme
                                                  .blueColorScheme()
                                              .secondaryContainer,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color.fromARGB(
                                                      255, 46, 49, 116)
                                                  .withOpacity(0.3),
                                              spreadRadius: 2,
                                              blurRadius: 9,
                                              offset: const Offset(1, 2),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10.0),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.all(15),
                                                child: Icon(
                                                    Icons
                                                        .local_shipping_outlined,
                                                    size: 50),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 15.0),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(children: [
                                                        const Icon(
                                                            Icons
                                                                .location_on_outlined,
                                                            size: 10),
                                                        const SizedBox(
                                                            width: 2),
                                                        Expanded(
                                                          child: Text(
                                                            order.deliveryAddress,
                                                            maxLines: 5,
                                                            overflow: TextOverflow
                                                                .ellipsis,
                                                            softWrap: true,
                                                            style: const TextStyle(
                                                                fontSize: 13.5,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                      ]),
                                                      const SizedBox(height: 4),
                                                      Text(order.trackingId,
                                                          style: const TextStyle(
                                                              fontSize: 11)),
                                                      const SizedBox(height: 3),
                                                      Text(
                                                          '~${order.distanceInKm} Km',
                                                          style: const TextStyle(
                                                              fontSize: 12)),
                                                      Text(
                                                          'Weight: ${order.weightInKg} Kg',
                                                          style: const TextStyle(
                                                              fontSize: 12)),
                                                      Text(
                                                          'Priority: ${order.urgencyLevel}',
                                                          style: const TextStyle(
                                                              fontSize: 12)),
                                                      Text(
                                                          'Price: ${order.wage}',
                                                          style: const TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(15),
                                                child: Transform.scale(
                                                  scale: 2,
                                                  child: Checkbox(
                                                    value: order.isSelected,
                                                    onChanged:
                                                        (bool? newValue) {
                                                      setState(() {
                                                        order.isSelected =
                                                            newValue ?? false;
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),

                      // ── Refresh FAB ───────────────────────────────────
                      Positioned(
                        bottom: 20,
                        right: 16,
                        child: FloatingActionButton(
                          heroTag: 'refreshOrders',
                          backgroundColor:
                              MaterialTheme.blueColorScheme().secondary,
                          foregroundColor: Colors.white,
                          tooltip: 'Refresh orders',
                          onPressed: _refreshAll,
                          child: const Icon(Icons.refresh),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

// ── Small helper model for stop data ──────────────────────────────────────────
class _StopInfo {
  final String orderId;
  final LatLng position;
  final String sequence;
  final String address;
  const _StopInfo({
    required this.orderId,
    required this.position,
    required this.sequence,
    required this.address,
  });
}

// ── EXISTING Order model — completely unchanged ────────────────────────────────
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
      distanceInKm: (json['distanceInKm'] ?? 0).toDouble(),
      weightInKg: (json['weightInKg'] ?? 0).toDouble(),
      urgencyLevel: json['urgencyLevel'] ?? '',
      wage: (json['wage'] ?? 0).toDouble(),
    );
  }
}