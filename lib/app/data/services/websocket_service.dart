import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WebSocketService {
  static WebSocketService? _instance;
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  final String _baseUrl = 'wss://barley-chimp-girdle.ngrok-free.dev';
  
  // Callbacks for location updates
  Function(Map<String, dynamic>)? onLocationUpdate;
  Function(String)? onOrderStatusUpdate;
  Function()? onConnected;
  Function(String)? onDisconnected;
  Function(String)? onError;

  WebSocketService._();

  static WebSocketService get instance {
    _instance ??= WebSocketService._();
    return _instance!;
  }

  Future<void> connect(String orderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null || token.isEmpty) {
        onError?.call('No authentication token found');
        return;
      }

      // Connect to WebSocket with order-specific room
      final uri = Uri.parse('$_baseUrl/ws/order/$orderId?token=$token');
      _channel = WebSocketChannel.connect(uri);

      _subscription = _channel!.stream.listen(
        (data) {
          _handleMessage(data);
        },
        onError: (error) {
          onError?.call('WebSocket error: $error');
        },
        onDone: () {
          onDisconnected?.call('WebSocket connection closed');
          // Attempt to reconnect after 5 seconds
          Timer(const Duration(seconds: 5), () => connect(orderId));
        },
      );

      onConnected?.call();
    } catch (e) {
      onError?.call('Failed to connect: $e');
    }
  }

  void _handleMessage(dynamic data) {
    try {
      final message = json.decode(data);
      
      switch (message['type']) {
        case 'location_update':
          onLocationUpdate?.call(message['data']);
          break;
        case 'order_status':
          onOrderStatusUpdate?.call(message['status']);
          break;
        case 'milestone':
          onOrderStatusUpdate?.call(message['milestone']);
          break;
      }
    } catch (e) {
      onError?.call('Failed to parse message: $e');
    }
  }

  void sendLocationUpdate(double lat, double lng) {
    if (_channel != null) {
      _channel!.sink.add(json.encode({
        'type': 'location_update',
        'data': {
          'lat': lat,
          'lng': lng,
          'timestamp': DateTime.now().toIso8601String(),
        },
      }));
    }
  }

  void sendOrderStatus(String orderId, String status) {
    if (_channel != null) {
      _channel!.sink.add(json.encode({
        'type': 'order_status',
        'orderId': orderId,
        'status': status,
        'timestamp': DateTime.now().toIso8601String(),
      }));
    }
  }

  void disconnect() {
    _subscription?.cancel();
    _channel?.sink.close();
    _channel = null;
    _subscription = null;
  }

  bool get isConnected => _channel != null;
}
