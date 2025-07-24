import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/trip.dart';
import '../providers/trip_provider.dart';
import '../widgets/trip_stats_card.dart';
import '../widgets/passenger_list_card.dart';
import '../widgets/trip_control_panel.dart';

class TripTrackingPage extends StatefulWidget {
  final Trip trip;

  const TripTrackingPage({super.key, required this.trip});

  @override
  State<TripTrackingPage> createState() =>
      _TripTrackingPageState();
}

class _TripTrackingPageState extends State<TripTrackingPage>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  Position? _currentPosition;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  Timer? _locationTimer;
  StreamSubscription<Position>? _positionStream;

  bool _isMapReady = false;
  bool _isTrackingLocation = false;
  double _currentSpeed = 0.0;

  // Bottom sheet controller
  late AnimationController _bottomSheetController;
  late Animation<Offset> _bottomSheetAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeLocationTracking();
    _setupTripTracking();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _bottomSheetController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _bottomSheetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _bottomSheetController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
    _bottomSheetController.forward();
  }

  void _initializeLocationTracking() async {
    // Check location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      _showLocationPermissionDialog();
      return;
    }

    // Start location tracking
    _startLocationTracking();
  }

  void _startLocationTracking() {
    setState(() {
      _isTrackingLocation = true;
    });

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      _updateLocation(position);
    });
  }

  void _updateLocation(Position position) {
    setState(() {
      _currentPosition = position;
      _currentSpeed = position.speed * 3.6; // Convert m/s to km/h
    });

    _updateMapLocation(position);
    _sendLocationToServer(position);
  }

  void _updateMapLocation(Position position) {
    final LatLng newLocation = LatLng(position.latitude, position.longitude);

    // Update camera position
    _mapController?.animateCamera(CameraUpdate.newLatLng(newLocation));

    // Update markers
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('current_location'),
          position: newLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
            title: 'Current Location',
            snippet: 'Speed: ${_currentSpeed.toStringAsFixed(1)} km/h',
          ),
        ),
        // Add route stops markers
        ..._getRouteStopMarkers(),
      };
    });
  }

  Set<Marker> _getRouteStopMarkers() {
    // This would come from your route data
    return {};
  }

  void _sendLocationToServer(Position position) {
    // final tripProvider = Provider.of<TripProvider>(context, listen: false);
    debugPrint('Location updated: ${position.latitude}, ${position.longitude}');
    // Send location update to server
    // tripProvider.updateTripLocation(
    //   tripId: widget.trip.tripId,
    //   latitude: position.latitude,
    //   longitude: position.longitude,
    //   speed: position.speed,
    //   heading: position.heading,
    // );
  }

  void _setupTripTracking() {
    // Initialize trip tracking components
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tripProvider = Provider.of<TripProvider>(context, listen: false);

      // Load trip passengers
      // tripProvider.getTripPassengers(widget.trip.tripId);

      // Start trip if not already started
      if (!widget.trip.isActive) {
        _showStartTripDialog();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bottomSheetController.dispose();
    _locationTimer?.cancel();
    _positionStream?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          _buildMap(),

          // Top Status Bar
          _buildTopStatusBar(),

          // Trip Controls Floating Button
          _buildFloatingControls(),

          // Bottom Panel
          _buildBottomPanel(),

          // Emergency Button
          _buildEmergencyButton(),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
        setState(() {
          _isMapReady = true;
        });
      },
      initialCameraPosition: CameraPosition(
        target:
            _currentPosition != null
                ? LatLng(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                )
                : const LatLng(-6.2088, 35.7395), // Dar es Salaam default
        zoom: 16.0,
      ),
      markers: _markers,
      polylines: _polylines,
      myLocationEnabled: false, // We'll use custom marker
      myLocationButtonEnabled: false,
      compassEnabled: true,
      trafficEnabled: true,
      buildingsEnabled: true,
      onCameraMove: (CameraPosition position) {
        // Handle camera movement if needed
      },
    );
  }

  Widget _buildTopStatusBar() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Back Button
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Trip Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.trip.route?.routeName ?? 'Unknown Route',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Consumer<TripProvider>(
                    builder: (context, tripProvider, child) {
                      final duration = DateTime.now().difference(
                        widget.trip.actualStartTime ?? widget.trip.startTime,
                      );

                      return Text(
                        '${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Speed Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getSpeedColor(),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentSpeed.toStringAsFixed(0)} km/h',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSpeedColor() {
    if (_currentSpeed < 10) return Colors.red;
    if (_currentSpeed < 30) return Colors.orange;
    if (_currentSpeed < 60) return AppTheme.successColor;
    return Colors.blue;
  }

  Widget _buildFloatingControls() {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.3,
      right: 16,
      child: Column(
        children: [
          // Center on location
          FloatingActionButton(
            mini: true,
            heroTag: "center_location",
            onPressed: _centerOnCurrentLocation,
            backgroundColor: Colors.white,
            child: Icon(Icons.my_location, color: AppTheme.primaryColor),
          ),

          const SizedBox(height: 8),

          // QR Scanner
          FloatingActionButton(
            mini: true,
            heroTag: "qr_scanner",
            onPressed: _openQRScanner,
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.qr_code_scanner, color: Colors.white),
          ),

          const SizedBox(height: 8),

          // Toggle tracking
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale:
                    _isTrackingLocation
                        ? 1.0 + (_pulseAnimation.value * 0.1)
                        : 1.0,
                child: FloatingActionButton(
                  mini: true,
                  heroTag: "toggle_tracking",
                  onPressed: _toggleLocationTracking,
                  backgroundColor:
                      _isTrackingLocation ? AppTheme.successColor : Colors.grey,
                  child: Icon(
                    _isTrackingLocation ? Icons.gps_fixed : Icons.gps_off,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _bottomSheetAnimation,
        child: Container(
          height: 280,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: DefaultTabController(
            length: 3,
            child: Column(
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Tab Bar
                TabBar(
                  labelColor: AppTheme.primaryColor,
                  unselectedLabelColor: AppTheme.textSecondaryColor,
                  indicatorColor: AppTheme.primaryColor,
                  tabs: const [
                    Tab(text: 'Stats'),
                    Tab(text: 'Passengers'),
                    Tab(text: 'Controls'),
                  ],
                ),

                // Tab Views
                Expanded(
                  child: TabBarView(
                    children: [
                      TripStatsCard(trip: widget.trip),
                      PassengerListCard(trip: widget.trip),
                      TripControlPanel(trip: widget.trip),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyButton() {
    return Positioned(
      bottom: 300,
      left: 16,
      child: FloatingActionButton(
        heroTag: "emergency",
        onPressed: _handleEmergency,
        backgroundColor: Colors.red,
        child: const Icon(Icons.emergency, color: Colors.white),
      ),
    );
  }

  void _centerOnCurrentLocation() {
    if (_currentPosition != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        ),
      );
    }
  }

  void _toggleLocationTracking() {
    if (_isTrackingLocation) {
      _positionStream?.cancel();
      setState(() {
        _isTrackingLocation = false;
      });
    } else {
      _startLocationTracking();
    }
  }

  void _openQRScanner() {
    Navigator.pushNamed(context, '/qr-scanner').then((result) {
      if (result != null && result is Map<String, dynamic>) {
        _handleQRScanResult(result);
      }
    });
  }

  void _handleQRScanResult(Map<String, dynamic> result) {
    final action = result['action'];
    final bookingId = result['booking_id'] as int?;

    if (action == 'board_passenger' && bookingId != null) {
      final tripProvider = Provider.of<TripProvider>(context, listen: false);
      tripProvider.markPassengerBoarded(bookingId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Passenger boarded successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  void _handleEmergency() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Emergency Alert'),
            content: const Text(
              'Are you sure you want to send an emergency alert?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _sendEmergencyAlert();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Send Alert'),
              ),
            ],
          ),
    );
  }

  void _sendEmergencyAlert() async {
    if (_currentPosition == null) return;

    // Send emergency alert to backend
    // This would typically include location, driver info, and trip details
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Emergency alert sent successfully'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showStartTripDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Start Trip'),
            content: const Text('Are you ready to start this trip?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context); // Go back to trip list
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _startTrip();
                },
                child: const Text('Start Trip'),
              ),
            ],
          ),
    );
  }

  void _startTrip() {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    tripProvider.startTrip(widget.trip.tripId);
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Location Permission Required'),
            content: const Text(
              'Location access is required for trip tracking. Please enable location permissions in settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Geolocator.openAppSettings();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
    );
  }
}
