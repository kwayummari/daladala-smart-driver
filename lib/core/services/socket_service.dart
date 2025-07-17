// lib/core/services/socket_service.dart
import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Event listeners
  final Map<String, List<Function(dynamic)>> _eventListeners = {};

  // Connection status stream
  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();
  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  String get socketUrl => dotenv.env['SOCKET_URL'] ?? 'http://10.0.2.2:3000';

  Future<void> initialize() async {
    print('🔌 SocketService: Initializing...');
    await _setupSocket();
  }

  Future<void> _setupSocket() async {
    try {
      final token = await _storage.read(key: 'driver_token');

      _socket = IO.io(
        socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .setAuth({'token': token, 'userType': 'driver'})
            .build(),
      );

      _setupEventListeners();
    } catch (e) {
      print('❌ Error setting up socket: $e');
    }
  }

  void _setupEventListeners() {
    _socket?.onConnect((_) {
      print('✅ Socket connected');
      _isConnected = true;
      _connectionStatusController.add(true);
      _joinDriverRoom();
    });

    _socket?.onDisconnect((_) {
      print('❌ Socket disconnected');
      _isConnected = false;
      _connectionStatusController.add(false);
    });

    _socket?.onConnectError((error) {
      print('❌ Socket connection error: $error');
      _isConnected = false;
      _connectionStatusController.add(false);
    });

    _socket?.onError((error) {
      print('❌ Socket error: $error');
    });

    // Driver-specific events
    _socket?.on('new_booking_request', (data) {
      print('🔔 New booking request received: $data');
      _notifyListeners('new_booking_request', data);
    });

    _socket?.on('booking_cancelled', (data) {
      print('❌ Booking cancelled: $data');
      _notifyListeners('booking_cancelled', data);
    });

    _socket?.on('passenger_boarding', (data) {
      print('👤 Passenger boarding: $data');
      _notifyListeners('passenger_boarding', data);
    });

    _socket?.on('trip_update', (data) {
      print('🚌 Trip update: $data');
      _notifyListeners('trip_update', data);
    });

    _socket?.on('emergency_alert', (data) {
      print('🚨 Emergency alert: $data');
      _notifyListeners('emergency_alert', data);
    });

    _socket?.on('driver_message', (data) {
      print('💬 Driver message: $data');
      _notifyListeners('driver_message', data);
    });
  }

  Future<void> _joinDriverRoom() async {
    try {
      final token = await _storage.read(key: 'driver_token');
      if (token != null && _socket != null) {
        _socket!.emit('join_driver_room', {'token': token});
        print('🏠 Joined driver room');
      }
    } catch (e) {
      print('❌ Error joining driver room: $e');
    }
  }

  // Connect to socket
  Future<void> connect() async {
    if (_socket == null) {
      await _setupSocket();
    }

    if (!_isConnected) {
      _socket?.connect();
    }
  }

  // Disconnect from socket
  void disconnect() {
    if (_isConnected) {
      _socket?.disconnect();
      _isConnected = false;
      _connectionStatusController.add(false);
    }
  }

  // Emit driver location update
  void emitLocationUpdate({
    required int tripId,
    required double latitude,
    required double longitude,
    double? speed,
    double? heading,
  }) {
    if (_isConnected && _socket != null) {
      _socket!.emit('driver_location_update', {
        'trip_id': tripId,
        'latitude': latitude,
        'longitude': longitude,
        'speed': speed,
        'heading': heading,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  // Emit trip status update
  void emitTripStatusUpdate({
    required int tripId,
    required String status,
    Map<String, dynamic>? additionalData,
  }) {
    if (_isConnected && _socket != null) {
      final data = {
        'trip_id': tripId,
        'status': status,
        'timestamp': DateTime.now().toIso8601String(),
      };

      if (additionalData != null) {
        data.addAll(additionalData.cast<String, Object>());
      }

      _socket!.emit('trip_status_update', data);
    }
  }

  // Emit passenger status update
  void emitPassengerStatusUpdate({
    required int bookingId,
    required String status,
    String? notes,
  }) {
    if (_isConnected && _socket != null) {
      _socket!.emit('passenger_status_update', {
        'booking_id': bookingId,
        'status': status,
        'notes': notes,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  // Emit driver status update
  void emitDriverStatusUpdate({
    required String status,
    bool? isAvailable,
    Map<String, dynamic>? additionalData,
  }) {
    if (_isConnected && _socket != null) {
      final data = {
        'status': status,
        'is_available': isAvailable,
        'timestamp': DateTime.now().toIso8601String(),
      };

      if (additionalData != null) {
        data.addAll(additionalData);
      }

      _socket!.emit('driver_status_update', data);
    }
  }

  // Emit emergency alert
  void emitEmergencyAlert({
    required String type,
    required String message,
    double? latitude,
    double? longitude,
    int? tripId,
  }) {
    if (_isConnected && _socket != null) {
      _socket!.emit('emergency_alert', {
        'type': type,
        'message': message,
        'latitude': latitude,
        'longitude': longitude,
        'trip_id': tripId,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  // Event listener management
  void addEventListener(String event, Function(dynamic) callback) {
    if (!_eventListeners.containsKey(event)) {
      _eventListeners[event] = [];
    }
    _eventListeners[event]!.add(callback);
  }

  void removeEventListener(String event, Function(dynamic) callback) {
    if (_eventListeners.containsKey(event)) {
      _eventListeners[event]!.remove(callback);
    }
  }

  void _notifyListeners(String event, dynamic data) {
    if (_eventListeners.containsKey(event)) {
      for (final callback in _eventListeners[event]!) {
        try {
          callback(data);
        } catch (e) {
          print('❌ Error in socket event callback: $e');
        }
      }
    }
  }

  // Getters
  bool get isConnected => _isConnected;
  IO.Socket? get socket => _socket;

  void dispose() {
    disconnect();
    _connectionStatusController.close();
    _eventListeners.clear();
    _socket?.dispose();
  }
}
