// lib/core/services/location_service.dart
import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  StreamSubscription<Position>? _positionSubscription;
  Position? _currentPosition;
  bool _isTracking = false;

  // Location update callbacks
  final List<Function(Position)> _locationUpdateCallbacks = [];

  // Location settings
  final LocationSettings _locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10, // Update every 10 meters
  );

  Future<void> initialize() async {
    print('🌍 LocationService: Initializing...');
    await _requestPermissions();
  }

  Future<bool> _requestPermissions() async {
    try {
      // Request location permission
      final locationStatus = await Permission.location.request();
      if (locationStatus != PermissionStatus.granted) {
        print('❌ Location permission denied');
        return false;
      }

      // Request background location permission for tracking
      final backgroundLocationStatus =
          await Permission.locationAlways.request();
      if (backgroundLocationStatus != PermissionStatus.granted) {
        print('⚠️ Background location permission denied');
        // Continue without background location for now
      }

      return true;
    } catch (e) {
      print('❌ Error requesting permissions: $e');
      return false;
    }
  }

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<Position?> getCurrentPosition() async {
    try {
      if (!await isLocationServiceEnabled()) {
        throw Exception('Location services are disabled');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _currentPosition = position;
      print('📍 Current position: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('❌ Error getting current position: $e');
      return null;
    }
  }

  Future<void> startLocationTracking() async {
    if (_isTracking) {
      print('⚠️ Location tracking already started');
      return;
    }

    try {
      if (!await isLocationServiceEnabled()) {
        throw Exception('Location services are disabled');
      }

      print('🚀 Starting location tracking...');
      _isTracking = true;

      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: _locationSettings,
      ).listen(
        (Position position) {
          _currentPosition = position;
          _notifyLocationUpdate(position);
        },
        onError: (error) {
          print('❌ Location tracking error: $error');
          _isTracking = false;
        },
      );
    } catch (e) {
      print('❌ Error starting location tracking: $e');
      _isTracking = false;
      throw e;
    }
  }

  Future<void> stopLocationTracking() async {
    if (!_isTracking) {
      return;
    }

    print('🛑 Stopping location tracking...');
    _isTracking = false;
    await _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  void addLocationUpdateCallback(Function(Position) callback) {
    _locationUpdateCallbacks.add(callback);
  }

  void removeLocationUpdateCallback(Function(Position) callback) {
    _locationUpdateCallbacks.remove(callback);
  }

  void _notifyLocationUpdate(Position position) {
    for (final callback in _locationUpdateCallbacks) {
      try {
        callback(position);
      } catch (e) {
        print('❌ Error in location update callback: $e');
      }
    }
  }

  // Calculate distance between two points
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  // Calculate bearing between two points
  double calculateBearing(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.bearingBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  // Check if driver is near a specific location (within radius)
  bool isNearLocation(
    double targetLatitude,
    double targetLongitude,
    double radiusInMeters,
  ) {
    if (_currentPosition == null) return false;

    final distance = calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      targetLatitude,
      targetLongitude,
    );

    return distance <= radiusInMeters;
  }

  // Get speed in km/h
  double? getSpeedKmh() {
    if (_currentPosition?.speed == null) return null;
    return (_currentPosition!.speed * 3.6); // Convert m/s to km/h
  }

  // Get heading/bearing
  double? getHeading() {
    return _currentPosition?.heading;
  }

  // Getters
  Position? get currentPosition => _currentPosition;
  bool get isTracking => _isTracking;

  // Get location update interval from env
  int get updateIntervalSeconds {
    final interval = dotenv.env['LOCATION_UPDATE_INTERVAL'];
    return int.tryParse(interval ?? '10') ?? 10;
  }

  void dispose() {
    stopLocationTracking();
    _locationUpdateCallbacks.clear();
  }
}
