import 'dart:async';
import 'dart:convert';
import 'package:courier/app/core/theme/theme.dart';
import 'package:courier/app/data/services/websocket_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  GoogleMapController? _mapController;
  bool _hasRoute = false;
  bool isTracking = false;
  Timer? _locationTimer;

  // ── Real-time services ───────────────────────────────────────────────────────
  final WebSocketService _wsService = WebSocketService.instance;
  String? _currentOrderId;
  StreamSubscription? _locationUpdateSubscription;

  // Hub / worker / stop data
  LatLng? _hubLatLng;
  LatLng? _workerLatLng;
  List<_StopInfo> _stops = [];

  // ── ORS road-following route polyline ──────────────────────────────────────
  List<LatLng> _routePoints = [];
  bool _isRouteLoading = false;

  // ── Track completed order IDs so marker stays green after refresh ──────────
  final Set<String> _completedOrderIds = {};

  // ── Track whether ALL stops are done so hub turns green ───────────────────
  bool get _allStopsCompleted =>
      _stops.isNotEmpty &&
      _stops.every((s) => _completedOrderIds.contains(s.orderId));

  static const String baseUrl =
      'https://barley-chimp-girdle.ngrok-free.dev';

  // ── OpenRouteService API key ───────────────────────────────────────────────
  // Sign up free at https://openrouteservice.org/dev/#/signup (email only)
  // then paste your key below.
  static const String orsApiKey = 'YOUR_OPENROUTESERVICE_API_KEY';

  @override
  void initState() {
    super.initState();
    _initializeServices();
    fetchOrders();
    fetchRoute();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _locationUpdateSubscription?.cancel();
    _wsService.disconnect();
    _mapController?.dispose();
    super.dispose();
  }

  // ── Initialize real-time services ────────────────────────────────────────────
  Future<void> _initializeServices() async {
    // Set up WebSocket callbacks
    _wsService.onLocationUpdate = (data) {
      if (mounted) {
        final lat = data['lat'] as double;
        final lng = data['lng'] as double;
        final pos = LatLng(lat, lng);
        setState(() => _workerLatLng = pos);
        _mapController?.animateCamera(CameraUpdate.newLatLng(pos));
      }
    };

    _wsService.onOrderStatusUpdate = (status) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order status: $status')),
        );
        fetchRoute(); // Refresh to get updated stop status
      }
    };

    _wsService.onError = (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('WebSocket error: $error')),
        );
      }
    };
  }

  // ── Logout helper ──────────────────────────────────────────────────────────
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _wsService.disconnect();
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

      // Fetch the road-following route through remaining stops, in order.
      _fetchOrsRoute();
    } catch (e) {
      print('Route fetch error: $e');
    }
  }

  // ── Fetch a real, road-following route from OpenRouteService ──────────────
  // Draws hub → stop 1 → stop 2 → ... (only stops NOT yet completed, in
  // sequence order) as a single driving-car route, then stores the returned
  // road geometry so it can be rendered as a Polyline.
  Future<void> _fetchOrsRoute() async {
    if (_hubLatLng == null) return;

    final pendingStops = _stops
        .where((s) => !_completedOrderIds.contains(s.orderId))
        .toList()
      ..sort((a, b) =>
          (int.tryParse(a.sequence) ?? 0).compareTo(int.tryParse(b.sequence) ?? 0));

    if (pendingStops.isEmpty) {
      if (mounted) setState(() => _routePoints = []);
      return;
    }

    final waypoints = [
      _hubLatLng!,
      ...pendingStops.map((s) => s.position),
    ];

    if (mounted) setState(() => _isRouteLoading = true);

    try {
      final response = await http.post(
        Uri.parse(
            'https://api.openrouteservice.org/v2/directions/driving-car/geojson'),
        headers: {
          'Authorization': orsApiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'coordinates':
              waypoints.map((p) => [p.longitude, p.latitude]).toList(),
        }),
      );

      if (response.statusCode != 200) {
        print('ORS route error: ${response.statusCode} ${response.body}');
        if (mounted) setState(() => _isRouteLoading = false);
        return;
      }

      final decoded = jsonDecode(response.body);
      final coords =
          decoded['features'][0]['geometry']['coordinates'] as List;
      final points = coords
          .map<LatLng>(
              (c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
          .toList();

      if (!mounted) return;
      setState(() {
        _routePoints = points;
        _isRouteLoading = false;
      });
    } catch (e) {
      print('ORS route fetch failed: $e');
      if (mounted) setState(() => _isRouteLoading = false);
    }
  }

  // ── Mark a stop as completed manually (tap the marker) ────────────────────
  void _markStopCompleted(String orderId) {
    setState(() => _completedOrderIds.add(orderId));

    // Send completion status via WebSocket
    _wsService.sendOrderStatus(orderId, 'delivered');

    // Trigger milestone notification via backend
    _sendMilestoneNotification(orderId, 'delivered');

    // Redraw the route without the just-completed stop
    _fetchOrsRoute();
  }

  // ── Send milestone notification to backend ───────────────────────────────────
  Future<void> _sendMilestoneNotification(String orderId, String milestone) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      await http.post(
        Uri.parse('$baseUrl/api/order/milestone'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'Meena',
        },
        body: jsonEncode({
          'orderId': orderId,
          'milestone': milestone,
        }),
      );
    } catch (e) {
      print('Failed to send milestone notification: $e');
    }
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

    // Connect to WebSocket for real-time location updates
    if (_stops.isNotEmpty) {
      _currentOrderId = _stops.first.orderId; // Use first order ID for room
      await _wsService.connect(_currentOrderId!);
    }

    // Send location updates via WebSocket every 5 seconds
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        final pos = LatLng(position.latitude, position.longitude);

        if (!mounted) return;
        setState(() => _workerLatLng = pos);

        _mapController?.animateCamera(CameraUpdate.newLatLng(pos));

        // Send location via WebSocket instead of HTTP
        _wsService.sendLocationUpdate(position.latitude, position.longitude);
      } catch (e) {
        print('Location update error: $e');
      }
    });
  }

  void stopTracking() {
    _locationTimer?.cancel();
    _wsService.disconnect();

    setState(() => isTracking = false);
  }

  // ── fit map bounds to all markers ─────────────────────────────────────────
  void _fitBounds() {
    if (_mapController == null) return;

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

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat - 0.01, minLng - 0.01),
          northeast: LatLng(maxLat + 0.01, maxLng + 0.01),
        ),
        60,
      ),
    );
  }

  // ── Build markers ──────────────────────────────────────────────────────────
  // NOTE: google_maps_flutter markers can't host arbitrary widget trees the
  // way flutter_map's Marker could, so custom badges/sequence overlays are
  // approximated with colored pins (hue) + InfoWindow title/snippet instead.
  Set<Marker> _buildMarkers() {
    final List<Marker> result = [];

    // ── Hub marker — blue normally, green when ALL stops completed ───────────
    if (_hubLatLng != null) {
      final bool hubDone = _allStopsCompleted;
      result.add(
        Marker(
          markerId: const MarkerId('hub'),
          position: _hubLatLng!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            hubDone ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueAzure,
          ),
          infoWindow: InfoWindow(
            title: hubDone
                ? '✅ All deliveries complete — return to hub'
                : '📦 Hub — Pick up here first',
          ),
        ),
      );
    }

    // ── Stop markers — red normally, green when completed ────────────────────
    for (final stop in _stops) {
      final bool done = _completedOrderIds.contains(stop.orderId);
      result.add(
        Marker(
          markerId: MarkerId('stop_${stop.orderId}'),
          position: stop.position,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            done ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed,
          ),
          infoWindow: InfoWindow(
            title: done
                ? '✅ Stop ${stop.sequence} delivered'
                : 'Stop ${stop.sequence}',
            snippet: stop.address,
          ),
          onTap: () => _showCompleteDialog(stop),
        ),
      );
    }

    // ── Worker / you-are-here marker ─────────────────────────────────────────
    if (_workerLatLng != null) {
      result.add(
        Marker(
          markerId: const MarkerId('worker'),
          position: _workerLatLng!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(title: '🚴 You are here'),
          zIndex: 2,
        ),
      );
    }

    return result.toSet();
  }

  // ── Build the road-following route polyline ────────────────────────────────
  Set<Polyline> _buildPolylines() {
    if (_routePoints.isEmpty) return {};
    return {
      Polyline(
        polylineId: const PolylineId('ors_route'),
        points: _routePoints,
        color: Colors.blueAccent,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ),
    };
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
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _hubLatLng ?? const LatLng(0, 0),
                          zoom: 13,
                        ),
                        minMaxZoomPreference:
                            const MinMaxZoomPreference(3, 19),
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: false,
                        myLocationButtonEnabled: false,
                        markers: _buildMarkers(),
                        polylines: _buildPolylines(),
                        onMapCreated: (controller) {
                          _mapController = controller;
                          WidgetsBinding.instance
                              .addPostFrameCallback((_) => _fitBounds());
                        },
                      ),

                      // ── Route loading indicator — top left ─────────────
                      if (_isRouteLoading)
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.all(8),
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
                            child: const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
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
                              onPressed: () => _mapController
                                  ?.animateCamera(CameraUpdate.zoomIn()),
                              child: const Icon(Icons.add),
                            ),
                            const SizedBox(height: 8),
                            FloatingActionButton.small(
                              heroTag: 'zoomOut',
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black87,
                              tooltip: 'Zoom out',
                              onPressed: () => _mapController
                                  ?.animateCamera(CameraUpdate.zoomOut()),
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