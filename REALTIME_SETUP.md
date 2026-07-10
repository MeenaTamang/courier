# Real-Time Courier Tracking & Milestone Alerts Setup

This document explains the implementation of real-time courier tracking and milestone push notifications.

## Overview

The app now uses:
- **WebSockets** for real-time courier location updates (push-based, no polling)
- **Firebase Cloud Messaging (FCM)** for milestone push notifications (works even when app is closed)

## Implementation Details

### 1. WebSocket Service (`lib/app/data/services/websocket_service.dart`)

**Purpose**: Real-time bidirectional communication for location updates.

**Features**:
- Connects to order-specific WebSocket rooms: `wss://your-domain/ws/order/{orderId}?token={jwt}`
- Receives location updates from backend instantly (no polling)
- Sends courier GPS coordinates every 5 seconds via WebSocket
- Handles order status updates and milestone events
- Auto-reconnects on connection loss

**Message Types**:
```json
// Location update sent by courier
{
  "type": "location_update",
  "data": {
    "lat": 27.7172,
    "lng": 85.3240,
    "timestamp": "2024-01-15T10:30:00Z"
  }
}

// Order status update received
{
  "type": "order_status",
  "status": "out_for_delivery"
}

// Milestone notification received
{
  "type": "milestone",
  "milestone": "courier_nearby"
}
```

### 2. FCM Service (`lib/app/data/services/fcm_service.dart`)

**Purpose**: Push notifications for milestone alerts.

**Features**:
- Registers FCM token with backend on app startup
- Subscribes to order-specific topics (`order_{orderId}`)
- Subscribes to worker-specific topics (`worker_{workerId}`)
- Handles foreground, background, and terminated app states
- Auto-refreshes FCM token when changed

**Milestone Notifications**:
- "Order out for delivery"
- "Courier is nearby"
- "Order delivered"
- These reach customers even when app is closed

### 3. Integration in Orders View

**Changes to `orders_view.dart`**:
- Initializes WebSocket and FCM services on startup
- Connects to WebSocket room when tracking starts
- Sends location updates via WebSocket (5s interval) instead of HTTP polling (15s)
- Subscribes to FCM topics for order and worker updates
- Handles incoming WebSocket messages to update map in real-time
- Sends milestone notifications to backend when order is delivered

## Backend Requirements

### WebSocket Server Implementation

Your backend needs a WebSocket server. Here's a reference implementation using Socket.IO (Node.js):

```javascript
// server.js
const express = require('express');
const http = require('http');
const socketIO = require('socket.io');

const app = express();
const server = http.createServer(app);
const io = socketIO(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

// Authentication middleware
io.use(async (socket, next) => {
  const token = socket.handshake.auth.token;
  // Verify JWT token here
  const decoded = jwt.verify(token, JWT_SECRET);
  socket.workerId = decoded.workerId;
  next();
});

// Order-specific rooms
io.on('connection', (socket) => {
  // Join order room
  socket.on('join_order', (orderId) => {
    socket.join(`order_${orderId}`);
  });

  // Receive location updates from courier
  socket.on('location_update', (data) => {
    // Broadcast to customers tracking this order
    socket.to(`order_${data.orderId}`).emit('location_update', data);
    
    // Store in database for customer app to fetch
    // updateCourierLocation(data.workerId, data.lat, data.lng);
  });

  // Order status updates
  socket.on('order_status', (data) => {
    io.to(`order_${data.orderId}`).emit('order_status', {
      status: data.status,
      timestamp: new Date()
    });
  });
});

server.listen(3000, () => {
  console.log('WebSocket server running on port 3000');
});
```

### FCM Backend Integration

Your backend needs to send FCM notifications for milestones:

```javascript
// Send milestone notification
const admin = require('firebase-admin');

async function sendMilestoneNotification(orderId, milestone, customerFcmToken) {
  const message = {
    notification: {
      title: 'Order Update',
      body: getMilestoneMessage(milestone)
    },
    data: {
      orderId: orderId,
      milestone: milestone,
      type: 'milestone'
    },
    token: customerFcmToken
  };

  await admin.messaging().send(message);
}

function getMilestoneMessage(milestone) {
  switch(milestone) {
    case 'out_for_delivery': return 'Your order is out for delivery!';
    case 'courier_nearby': return 'Courier is nearby - get ready!';
    case 'delivered': return 'Your order has been delivered!';
    default: return 'Order status updated';
  }
}
```

### Required Backend Endpoints

1. **POST /api/user/fcm-token** - Register FCM token
   ```json
   {
     "fcmToken": "device_fcm_token"
   }
   ```

2. **POST /api/order/milestone** - Trigger milestone notification
   ```json
   {
     "orderId": "123",
     "milestone": "delivered"
   }
   ```

3. **WebSocket endpoint**: `wss://your-domain/ws/order/{orderId}?token={jwt}`

## Firebase Setup

### 1. Create Firebase Project
- Go to https://console.firebase.google.com
- Create new project
- Add Android app (package: `com.example.courier`)
- Add iOS app (bundle: `com.example.courier`)

### 2. Download Config Files
- **Android**: Download `google-services.json` and place in `android/app/`
- **iOS**: Download `GoogleService-Info.plist` and place in `ios/Runner/`

### 3. Enable Cloud Messaging
- In Firebase Console, go to Project Settings > Cloud Messaging
- Enable Cloud Messaging API
- Get your Server Key and Sender ID

### 4. Update Config Files
Replace placeholder values in:
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

With your actual Firebase project values.

## Installation Steps

1. **Install dependencies**:
   ```bash
   flutter pub get
   ```

2. **Configure Firebase**:
   - Replace placeholder values in config files with your Firebase project details
   - For Android: `android/app/google-services.json`
   - For iOS: `ios/Runner/GoogleService-Info.plist`

3. **Run the app**:
   ```bash
   flutter run
   ```

## Testing

### Test WebSocket Connection
1. Start tracking in the app
2. Check console for WebSocket connection logs
3. Move courier location - map should update in real-time

### Test FCM Notifications
1. Trigger a milestone from backend:
   ```bash
   curl -X POST https://your-domain/api/order/milestone \
     -H "Authorization: Bearer YOUR_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"orderId": "123", "milestone": "delivered"}'
   ```
2. Notification should appear on device even if app is closed

## Benefits Over Polling

**Before (Polling)**:
- HTTP request every 15 seconds
- Laggy updates (up to 15s delay)
- High battery/data usage
- Server load from constant requests

**After (WebSocket + FCM)**:
- Instant location updates via WebSocket
- Push notifications work when app is closed
- Lower battery/data usage
- Reduced server load
- Better user experience

## Troubleshooting

**WebSocket connection fails**:
- Check ngrok tunnel is active
- Verify JWT token is valid
- Check backend WebSocket server is running

**FCM notifications not received**:
- Verify Firebase config files are correct
- Check app has notification permissions
- Test with Firebase Console test message
- Check backend is sending to correct FCM token

**Location updates not showing**:
- Ensure location permission is granted
- Check GPS is enabled
- Verify WebSocket connection is active
