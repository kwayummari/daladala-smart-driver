// lib/core/services/qr_service.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
// import 'package:vibration/vibration.dart';

class QRService {
  static final QRService _instance = QRService._internal();
  factory QRService() => _instance;
  QRService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isCameraPermissionGranted = false;

  Future<void> initialize() async {
    await _requestCameraPermission();
    await _loadScanSound();
  }

  Future<bool> _requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      _isCameraPermissionGranted = status == PermissionStatus.granted;

      if (!_isCameraPermissionGranted) {
        print('❌ Camera permission denied');
      } else {
        print('✅ Camera permission granted');
      }

      return _isCameraPermissionGranted;
    } catch (e) {
      print('❌ Error requesting camera permission: $e');
      return false;
    }
  }

  Future<void> _loadScanSound() async {
    try {
      // Load scan success sound
      await _audioPlayer.setSource(AssetSource('sounds/scan_success.mp3'));
    } catch (e) {
      print('⚠️ Could not load scan sound: $e');
    }
  }

  bool get isCameraPermissionGranted => _isCameraPermissionGranted;

  // Parse and validate QR code data
  Map<String, dynamic>? parseQRData(String qrCode) {
    try {
      final data = json.decode(qrCode);

      // Validate required fields
      if (data is Map<String, dynamic>) {
        final requiredFields = ['booking_id', 'validation_code', 'expires_at'];

        for (final field in requiredFields) {
          if (!data.containsKey(field)) {
            print('❌ Missing required field: $field');
            return null;
          }
        }

        // Check if QR code has expired
        final expiresAt = DateTime.tryParse(data['expires_at']);
        if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
          throw Exception('QR code has expired');
        }

        return data;
      }
    } catch (e) {
      print('❌ Error parsing QR data: $e');
      if (e.toString().contains('expired')) {
        rethrow;
      }
    }

    return null;
  }

  // Validate booking QR code structure
  bool isValidBookingQR(Map<String, dynamic> qrData) {
    try {
      // Check if it's a booking QR
      if (qrData['type'] != 'booking_ticket') {
        return false;
      }

      // Validate booking data structure
      final bookingData = qrData['booking_data'];
      if (bookingData == null) return false;

      final requiredBookingFields = [
        'booking_id',
        'passenger_name',
        'route_name',
        'status',
      ];

      for (final field in requiredBookingFields) {
        if (!bookingData.containsKey(field)) {
          return false;
        }
      }

      return true;
    } catch (e) {
      print('❌ Error validating booking QR: $e');
      return false;
    }
  }

  // Extract passenger information from QR
  Map<String, dynamic>? extractPassengerInfo(Map<String, dynamic> qrData) {
    try {
      if (!isValidBookingQR(qrData)) {
        return null;
      }

      final bookingData = qrData['booking_data'];

      return {
        'booking_id': bookingData['booking_id'],
        'passenger_name': bookingData['passenger_name'],
        'route_name': bookingData['route_name'],
        'seat_numbers': bookingData['seat_numbers'],
        'passenger_count': bookingData['passenger_count'] ?? 1,
        'status': bookingData['status'],
        'pickup_stop': bookingData['pickup_stop'],
        'dropoff_stop': bookingData['dropoff_stop'],
      };
    } catch (e) {
      print('❌ Error extracting passenger info: $e');
      return null;
    }
  }

  // Play scan feedback
  Future<void> playScanSuccess() async {
    try {
      // Play sound
      await _audioPlayer.play(AssetSource('sounds/scan_success.mp3'));

      // Vibrate
      // if (await Vibration.hasVibrator() ?? false) {
      //   Vibration.vibrate(duration: 200);
      // }

      // Haptic feedback
      HapticFeedback.lightImpact();
    } catch (e) {
      print('⚠️ Error playing scan feedback: $e');
      // Fallback to haptic feedback only
      HapticFeedback.lightImpact();
    }
  }

  Future<void> playScanError() async {
    try {
      // Play error sound (longer vibration)
      // if (await Vibration.hasVibrator() ?? false) {
      //   Vibration.vibrate(duration: 500);
      // }

      // Error haptic feedback
      HapticFeedback.heavyImpact();
    } catch (e) {
      print('⚠️ Error playing scan error feedback: $e');
      HapticFeedback.heavyImpact();
    }
  }

  // Generate summary for scanned booking
  String generateBookingSummary(Map<String, dynamic> passengerInfo) {
    final passengerName = passengerInfo['passenger_name'] ?? 'Unknown';
    final seatNumbers = passengerInfo['seat_numbers'];
    final passengerCount = passengerInfo['passenger_count'] ?? 1;

    String summary = 'Passenger: $passengerName\n';
    summary += 'Passengers: $passengerCount\n';

    if (seatNumbers != null && seatNumbers.isNotEmpty) {
      summary += 'Seats: $seatNumbers\n';
    }

    final pickupStop = passengerInfo['pickup_stop'];
    final dropoffStop = passengerInfo['dropoff_stop'];

    if (pickupStop != null) {
      summary += 'From: $pickupStop\n';
    }

    if (dropoffStop != null) {
      summary += 'To: $dropoffStop';
    }

    return summary;
  }

  // Check if QR code is from today
  bool isQRFromToday(Map<String, dynamic> qrData) {
    try {
      final createdAt = qrData['created_at'];
      if (createdAt != null) {
        final qrDate = DateTime.tryParse(createdAt);
        if (qrDate != null) {
          final today = DateTime.now();
          return qrDate.year == today.year &&
              qrDate.month == today.month &&
              qrDate.day == today.day;
        }
      }
      return true; // Assume valid if no date
    } catch (e) {
      return true; // Assume valid if error
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
