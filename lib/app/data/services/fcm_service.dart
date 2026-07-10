import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static const String _baseUrl = 'https://barley-chimp-girdle.ngrok-free.dev';

  // Callbacks for handling notifications
  Function(Map<String, dynamic>)? onNotificationReceived;
  Function(String)? onTokenRefresh;

  Future<void> initialize() async {
    // Request notification permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      print('Notification permission granted: ${settings.authorizationStatus}');
    }

    // Get initial message if app was opened from notification
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleMessage);

    // Handle messages when app is in background but opened
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    // Handle token refresh
    _messaging.onTokenRefresh.listen((token) {
      onTokenRefresh?.call(token);
      _registerTokenWithServer(token);
    });

    // Get current token and register with server
    String? token = await _messaging.getToken();
    if (token != null) {
      await _registerTokenWithServer(token);
    }
  }

  void _handleMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Received notification: ${message.notification?.title}');
      print('Data: ${message.data}');
    }

    Map<String, dynamic> notificationData = {
      'title': message.notification?.title,
      'body': message.notification?.body,
      'data': message.data,
    };

    onNotificationReceived?.call(notificationData);
  }

  Future<void> _registerTokenWithServer(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('token');

      if (authToken == null || authToken.isEmpty) {
        if (kDebugMode) print('No auth token found for FCM registration');
        return;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/api/user/fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
          'ngrok-skip-browser-warning': 'Meena',
        },
        body: jsonEncode({'fcmToken': token}),
      );

      if (kDebugMode) {
        print('FCM token registration status: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('Failed to register FCM token: $e');
    }
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  // Subscribe to a specific order's topic for milestone notifications
  Future<void> subscribeToOrder(String orderId) async {
    await _messaging.subscribeToTopic('order_$orderId');
    if (kDebugMode) print('Subscribed to order_$orderId topic');
  }

  // Unsubscribe from order topic
  Future<void> unsubscribeFromOrder(String orderId) async {
    await _messaging.unsubscribeFromTopic('order_$orderId');
    if (kDebugMode) print('Unsubscribed from order_$orderId topic');
  }

  // Subscribe to worker-specific updates
  Future<void> subscribeToWorkerUpdates(int workerId) async {
    await _messaging.subscribeToTopic('worker_$workerId');
    if (kDebugMode) print('Subscribed to worker_$workerId topic');
  }

  Future<void> unsubscribeFromWorkerUpdates(int workerId) async {
    await _messaging.unsubscribeFromTopic('worker_$workerId');
    if (kDebugMode) print('Unsubscribed from worker_$workerId topic');
  }
}
