// lib/features/trip/presentation/providers/trip_provider.dart
import 'dart:async';
import 'package:daladala_smart_driver/features/trip/domain/usecases/end_trip_usecase.dart';
import 'package:daladala_smart_driver/features/trip/domain/usecases/get_driver_trips_usecase.dart';
import 'package:daladala_smart_driver/features/trip/domain/usecases/get_trip_passengers_usecase.dart';
import 'package:daladala_smart_driver/features/trip/domain/usecases/manage_passenger_usecase.dart';
import 'package:daladala_smart_driver/features/trip/domain/usecases/start_trip_usecase.dart';
import 'package:daladala_smart_driver/features/trip/domain/usecases/update_location_usecase.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/socket_service.dart';
import '../../domain/entities/trip.dart';

enum TripState { initial, loading, loaded, error }

class TripProvider extends ChangeNotifier {
  final GetDriverTripsUseCase getDriverTripsUseCase;
  final StartTripUseCase startTripUseCase;
  final EndTripUseCase endTripUseCase;
  final UpdateLocationUseCase updateLocationUseCase;
  final GetTripPassengersUseCase getTripPassengersUseCase;
  final MarkPassengerBoardedUseCase markPassengerBoardedUseCase;
  final MarkPassengerDisembarkedUseCase markPassengerDisembarkedUseCase;
  final LocationService locationService;
  final SocketService socketService;
  // final NotificationService notificationService;

  TripProvider({
    required this.getDriverTripsUseCase,
    required this.startTripUseCase,
    required this.endTripUseCase,
    required this.updateLocationUseCase,
    required this.getTripPassengersUseCase,
    required this.markPassengerBoardedUseCase,
    required this.markPassengerDisembarkedUseCase,
    required this.locationService,
    required this.socketService,
    // required this.notificationService,
  }) {
    _setupLocationTracking();
    _setupSocketListeners();
  }

  TripState _state = TripState.initial;
  List<Trip> _trips = [];
  Trip? _activeTrip;
  List<TripPassenger> _currentPassengers = [];
  String? _errorMessage;
  bool _isLoading = false;
  bool _isLocationTracking = false;

  Timer? _locationUpdateTimer;
  StreamSubscription<Position>? _locationSubscription;

  // Getters
  TripState get state => _state;
  List<Trip> get trips => _trips;
  Trip? get activeTrip => _activeTrip;
  List<TripPassenger> get currentPassengers => _currentPassengers;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isLocationTracking => _isLocationTracking;

  // Computed properties
  List<Trip> get todayTrips {
    final today = DateTime.now();
    return _trips.where((trip) {
      return trip.startTime.year == today.year &&
          trip.startTime.month == today.month &&
          trip.startTime.day == today.day;
    }).toList();
  }

  int get todayTripsCount => todayTrips.length;

  double get todayEarnings {
    return todayTrips.fold(
      0.0,
      (total, trip) => total + (trip.earnings ?? 0.0),
    );
  }

  bool get hasActiveTrip => _activeTrip != null && _activeTrip!.isActive;

  // Load trips
  Future<void> loadDriverTrips({
    String? status,
    String? date,
    bool refresh = false,
  }) async {
    if (!refresh && _state == TripState.loading) return;

    try {
      _setLoading(true);
      _clearError();

      final result = await getDriverTripsUseCase(
        GetDriverTripsParams(status: status, date: date),
      );

      result.fold((failure) => _setError(failure.message), (trips) {
        _trips = trips;
        _findActiveTrip();
        _setState(TripState.loaded);
      });
    } catch (e) {
      _setError('Failed to load trips: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load today's trips specifically
  Future<void> loadTodayTrips() async {
    final today = DateTime.now();
    final dateString =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    await loadDriverTrips(date: dateString);
  }

  // Start trip
  Future<bool> startTrip(int tripId) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await startTripUseCase(StartTripParams(tripId: tripId));

      return result.fold(
        (failure) {
          _setError(failure.message);
          return false;
        },
        (success) {
          // Find and update the trip
          final tripIndex = _trips.indexWhere((t) => t.tripId == tripId);
          if (tripIndex != -1) {
            final updatedTrip = Trip(
              tripId: _trips[tripIndex].tripId,
              scheduleId: _trips[tripIndex].scheduleId,
              routeId: _trips[tripIndex].routeId,
              driverId: _trips[tripIndex].driverId,
              vehicleId: _trips[tripIndex].vehicleId,
              startTime: _trips[tripIndex].startTime,
              endTime: _trips[tripIndex].endTime,
              actualStartTime: DateTime.now(),
              actualEndTime: null,
              status: 'in_progress',
              currentStopId: _trips[tripIndex].currentStopId,
              nextStopId: _trips[tripIndex].nextStopId,
              driverLatitude: _trips[tripIndex].driverLatitude,
              driverLongitude: _trips[tripIndex].driverLongitude,
              lastDriverUpdate: DateTime.now(),
              currentPassengers: _trips[tripIndex].currentPassengers,
              earnings: _trips[tripIndex].earnings,
              createdAt: _trips[tripIndex].createdAt,
              updatedAt: DateTime.now(),
              route: _trips[tripIndex].route,
              vehicle: _trips[tripIndex].vehicle,
              passengers: _trips[tripIndex].passengers,
            );

            _trips[tripIndex] = updatedTrip;
            _activeTrip = updatedTrip;

            // Start location tracking
            _startLocationTracking();

            // Load passengers for this trip
            _loadTripPassengers(tripId);

            // Send socket notification
            socketService.emitTripStatusUpdate(
              tripId: tripId,
              status: 'in_progress',
            );

            // Show notification
            // notificationService.showTripStartedNotification(
            //   route: _activeTrip!.route?.routeName ?? 'Unknown Route',
            //   tripId: tripId,
            // );

            notifyListeners();
          }
          return true;
        },
      );
    } catch (e) {
      _setError('Failed to start trip: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // End trip
  Future<bool> endTrip(int tripId) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await endTripUseCase(EndTripParams(tripId: tripId));

      return result.fold(
        (failure) {
          _setError(failure.message);
          return false;
        },
        (success) {
          // Find and update the trip
          final tripIndex = _trips.indexWhere((t) => t.tripId == tripId);
          if (tripIndex != -1) {
            final updatedTrip = Trip(
              tripId: _trips[tripIndex].tripId,
              scheduleId: _trips[tripIndex].scheduleId,
              routeId: _trips[tripIndex].routeId,
              driverId: _trips[tripIndex].driverId,
              vehicleId: _trips[tripIndex].vehicleId,
              startTime: _trips[tripIndex].startTime,
              endTime: _trips[tripIndex].endTime,
              actualStartTime: _trips[tripIndex].actualStartTime,
              actualEndTime: DateTime.now(),
              status: 'completed',
              currentStopId: _trips[tripIndex].currentStopId,
              nextStopId: _trips[tripIndex].nextStopId,
              driverLatitude: _trips[tripIndex].driverLatitude,
              driverLongitude: _trips[tripIndex].driverLongitude,
              lastDriverUpdate: DateTime.now(),
              currentPassengers: _trips[tripIndex].currentPassengers,
              earnings: _trips[tripIndex].earnings,
              createdAt: _trips[tripIndex].createdAt,
              updatedAt: DateTime.now(),
              route: _trips[tripIndex].route,
              vehicle: _trips[tripIndex].vehicle,
              passengers: _trips[tripIndex].passengers,
            );

            _trips[tripIndex] = updatedTrip;

            // Stop location tracking
            _stopLocationTracking();

            // Clear active trip and passengers
            _activeTrip = null;
            _currentPassengers.clear();

            // Send socket notification
            socketService.emitTripStatusUpdate(
              tripId: tripId,
              status: 'completed',
            );

            // Show completion notification
            // notificationService.showTripCompletedNotification(
            //   route: updatedTrip.route?.routeName ?? 'Unknown Route',
            //   earnings: updatedTrip.earnings ?? 0.0,
            //   tripId: tripId,
            // );

            notifyListeners();
          }
          return true;
        },
      );
    } catch (e) {
      _setError('Failed to end trip: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Load trip passengers
  Future<void> _loadTripPassengers(int tripId) async {
    try {
      final result = await getTripPassengersUseCase(
        GetTripPassengersParams(tripId: tripId),
      );

      result.fold(
        (failure) => print('Failed to load passengers: ${failure.message}'),
        (passengers) {
          _currentPassengers = passengers;
          notifyListeners();
        },
      );
    } catch (e) {
      print('Error loading passengers: $e');
    }
  }

  // Mark passenger as boarded
  Future<bool> markPassengerBoarded(int bookingId) async {
    try {
      final result = await markPassengerBoardedUseCase(
        PassengerActionParams(bookingId: bookingId),
      );

      return result.fold(
        (failure) {
          _setError(failure.message);
          return false;
        },
        (success) {
          // Update passenger status locally
          final passengerIndex = _currentPassengers.indexWhere(
            (p) => p.bookingId == bookingId,
          );

          if (passengerIndex != -1) {
            final passenger = _currentPassengers[passengerIndex];
            _currentPassengers[passengerIndex] = TripPassenger(
              bookingId: passenger.bookingId,
              passengerName: passenger.passengerName,
              passengerPhone: passenger.passengerPhone,
              passengerCount: passenger.passengerCount,
              seatNumbers: passenger.seatNumbers,
              pickupStopName: passenger.pickupStopName,
              dropoffStopName: passenger.dropoffStopName,
              status: 'boarded',
              fareAmount: passenger.fareAmount,
              bookingTime: passenger.bookingTime,
              boardingTime: DateTime.now(),
              disembarkingTime: passenger.disembarkingTime,
            );

            // Send socket notification
            socketService.emitPassengerStatusUpdate(
              bookingId: bookingId,
              status: 'boarded',
            );

            // Show notification
            // notificationService.showPassengerBoardingNotification(
            //   passengerName: passenger.passengerName,
            //   seatNumber: passenger.seatNumbers ?? 'N/A',
            //   bookingId: bookingId,
            // );

            notifyListeners();
          }
          return true;
        },
      );
    } catch (e) {
      _setError('Failed to mark passenger as boarded: $e');
      return false;
    }
  }

  // Mark passenger as disembarked
  Future<bool> markPassengerDisembarked(int bookingId) async {
    try {
      final result = await markPassengerDisembarkedUseCase(
        PassengerActionParams(bookingId: bookingId),
      );

      return result.fold(
        (failure) {
          _setError(failure.message);
          return false;
        },
        (success) {
          // Update passenger status locally
          final passengerIndex = _currentPassengers.indexWhere(
            (p) => p.bookingId == bookingId,
          );

          if (passengerIndex != -1) {
            final passenger = _currentPassengers[passengerIndex];
            _currentPassengers[passengerIndex] = TripPassenger(
              bookingId: passenger.bookingId,
              passengerName: passenger.passengerName,
              passengerPhone: passenger.passengerPhone,
              passengerCount: passenger.passengerCount,
              seatNumbers: passenger.seatNumbers,
              pickupStopName: passenger.pickupStopName,
              dropoffStopName: passenger.dropoffStopName,
              status: 'disembarked',
              fareAmount: passenger.fareAmount,
              bookingTime: passenger.bookingTime,
              boardingTime: passenger.boardingTime,
              disembarkingTime: DateTime.now(),
            );

            // Send socket notification
            socketService.emitPassengerStatusUpdate(
              bookingId: bookingId,
              status: 'disembarked',
            );

            notifyListeners();
          }
          return true;
        },
      );
    } catch (e) {
      _setError('Failed to mark passenger as disembarked: $e');
      return false;
    }
  }

  // Location tracking methods
  void _setupLocationTracking() {
    locationService.addLocationUpdateCallback(_onLocationUpdate);
  }

  void _startLocationTracking() {
    if (_isLocationTracking || _activeTrip == null) return;

    _isLocationTracking = true;
    locationService.startLocationTracking();

    // Start periodic location updates
    _locationUpdateTimer = Timer.periodic(
      Duration(seconds: locationService.updateIntervalSeconds),
      (_) => _sendLocationUpdate(),
    );

    notifyListeners();
  }

  void _stopLocationTracking() {
    if (!_isLocationTracking) return;

    _isLocationTracking = false;
    locationService.stopLocationTracking();
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;

    notifyListeners();
  }

  void _onLocationUpdate(Position position) {
    if (_activeTrip != null) {
      _sendLocationUpdate();
    }
  }

  Future<void> _sendLocationUpdate() async {
    if (_activeTrip == null) return;

    final position = locationService.currentPosition;
    if (position == null) return;

    try {
      final locationUpdate = LocationUpdate(
        latitude: position.latitude,
        longitude: position.longitude,
        speed: position.speed,
        heading: position.heading,
        timestamp: DateTime.now(),
        tripId: _activeTrip!.tripId,
      );

      await updateLocationUseCase(
        UpdateLocationParams(locationUpdate: locationUpdate),
      );

      // Send real-time location via socket
      socketService.emitLocationUpdate(
        tripId: _activeTrip!.tripId,
        latitude: position.latitude,
        longitude: position.longitude,
        speed: position.speed,
        heading: position.heading,
      );
    } catch (e) {
      print('Failed to update location: $e');
    }
  }

  // Socket event listeners
  void _setupSocketListeners() {
    socketService.addEventListener('new_booking_request', _onNewBookingRequest);
    socketService.addEventListener('booking_cancelled', _onBookingCancelled);
    socketService.addEventListener('trip_update', _onTripUpdate);
  }

  void _onNewBookingRequest(dynamic data) {
    // Handle new booking request
    // notificationService.showNewBookingNotification(
    //   passengerName: data['passenger_name'] ?? 'Unknown Passenger',
    //   route: data['route_name'] ?? 'Unknown Route',
    //   pickupLocation: data['pickup_location'] ?? 'Unknown Location',
    //   bookingId: data['booking_id'],
    // );
  }

  void _onBookingCancelled(dynamic data) {
    // Handle booking cancellation
    final bookingId = data['booking_id'];
    _currentPassengers.removeWhere((p) => p.bookingId == bookingId);
    notifyListeners();
  }

  void _onTripUpdate(dynamic data) {
    // Handle trip updates from server
    final tripId = data['trip_id'];
    final status = data['status'];

    final tripIndex = _trips.indexWhere((t) => t.tripId == tripId);
    if (tripIndex != -1) {
      // Update trip status locally
      loadDriverTrips(refresh: true);
    }
  }

  // Helper methods
  void _findActiveTrip() {
    _activeTrip = _trips.firstWhere(
      (trip) => trip.isActive,
      orElse: () => null as Trip,
    );

    if (_activeTrip != null) {
      _loadTripPassengers(_activeTrip!.tripId);
      if (!_isLocationTracking) {
        _startLocationTracking();
      }
    }
  }

  void _setState(TripState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _state = TripState.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    if (_state == TripState.error) {
      _state = TripState.initial;
    }
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  @override
  void dispose() {
    _stopLocationTracking();
    _locationSubscription?.cancel();
    socketService.removeEventListener(
      'new_booking_request',
      _onNewBookingRequest,
    );
    socketService.removeEventListener('booking_cancelled', _onBookingCancelled);
    socketService.removeEventListener('trip_update', _onTripUpdate);
    super.dispose();
  }
}
