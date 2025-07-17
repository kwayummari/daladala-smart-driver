// lib/features/trip/presentation/pages/trip_tracking_page.dart
import 'dart:async';
import 'package:daladala_smart_driver/features/trip/presentation/widgets/trip_control_panel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/location_service.dart';
import '../../domain/entities/trip.dart';
import '../providers/trip_provider.dart';
import '../widgets/trip_stats_card.dart';
import '../widgets/passenger_list_card.dart';

class TripTrackingPage extends StatefulWidget {
  final Trip trip;

  const TripTrackingPage({super.key, required this.trip});

  @override
  State<TripTrackingPage> createState() => _TripTrackingPageState();
}

class _TripTrackingPageState extends State<TripTrackingPage> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  LatLng? _currentLocation;
  Timer? _locationTimer;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _initializeTracking();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializeTracking() async {
    final locationService = Provider.of<LocationService>(context, listen: false);
    
    // Get current location
    final position = await locationService.getCurrentPosition();
    if (position != null) {
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
      _updateDriverMarker();
    }

    // Start location updates
    _startLocationUpdates();
  }

  void _startLocationUpdates() {
    final locationService = Provider.of<LocationService>(context, listen: false);
    
    locationService.addLocationUpdateCallback((position) {
      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
        _updateDriverMarker();
        _animateToCurrentLocation();
      }
    });
  }

  void _updateDriverMarker() {
    if (_currentLocation == null) return;

    final driverMarker = Marker(
      markerId: const MarkerId('driver'),
      position: _currentLocation!,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: InfoWindow(
        title: 'Your Location',
        snippet: 'Driver: ${widget.trip.route?.routeName ?? 'Unknown Route'}',
      ),
    );

    setState(() {
      _markers.removeWhere((marker) => marker.markerId.value == 'driver');
      _markers.add(driverMarker);
    });
  }

  void _animateToCurrentLocation() {
    if (_mapController != null && _currentLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(_currentLocation!),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() {
      _isMapReady = true;
    });
    
    if (_currentLocation != null) {
      _animateToCurrentLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _currentLocation ?? const LatLng(-6.8162, 39.2803), // Dar es Salaam
              zoom: 15.0,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // Top App Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTopAppBar(),
          ),

          // Bottom Panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomPanel(),
          ),

          // Floating Action Buttons
          Positioned(
            right: 16,
            bottom: 300,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'location',
                  mini: true,
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryColor,
                  onPressed: _animateToCurrentLocation,
                  child: const Icon(Icons.my_location),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'qr',
                  mini: true,
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  onPressed: _openQRScanner,
                  child: const Icon(Icons.qr_code_scanner),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopAppBar() {
    final timeFormatter = DateFormat('HH:mm');
    final duration = widget.trip.actualStartTime != null 
        ? DateTime.now().difference(widget.trip.actualStartTime!)
        : Duration.zero;

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back, color: AppTheme.primaryColor),
            ),
            
            const SizedBox(width: 8),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.trip.route?.routeName ?? 'Unknown Route',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  Text(
                    'Started at ${timeFormatter.format(widget.trip.actualStartTime ?? widget.trip.startTime)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.successColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
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
    );
  }

  void _openQRScanner() {
    Navigator.pushNamed(context, '/qr-scanner').then((result) {
      if (result != null && result is Map<String, dynamic>) {
        final action = result['action'];
        if (action == 'board_passenger') {
          _handlePassengerBoarded(result);
        }
      }
    });
  }

  void _handlePassengerBoarded(Map<String, dynamic> result) {
    final bookingId = result['booking_id'] as int?;
    final passengerName = result['passenger_name'] as String?;

    if (bookingId != null) {
      final tripProvider = Provider.of<TripProvider>(context, listen: false);
      tripProvider.markPassengerBoarded(bookingId).then((success) {
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${passengerName ?? 'Passenger'} has boarded'),
              backgroundColor: AppTheme.successColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
    }
  }
}
