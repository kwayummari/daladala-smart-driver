// lib/features/trip/domain/entities/trip.dart
import 'package:equatable/equatable.dart';

class Trip extends Equatable {
  final int tripId;
  final int scheduleId;
  final int routeId;
  final int? driverId;
  final int? vehicleId;
  final DateTime startTime;
  final DateTime? endTime;
  final DateTime? actualStartTime;
  final DateTime? actualEndTime;
  final String status;
  final int? currentStopId;
  final int? nextStopId;
  final double? driverLatitude;
  final double? driverLongitude;
  final DateTime? lastDriverUpdate;
  final int? currentPassengers;
  final double? earnings;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related entities
  final TripRoute? route;
  final TripVehicle? vehicle;
  final List<TripPassenger>? passengers;

  const Trip({
    required this.tripId,
    required this.scheduleId,
    required this.routeId,
    this.driverId,
    this.vehicleId,
    required this.startTime,
    this.endTime,
    this.actualStartTime,
    this.actualEndTime,
    required this.status,
    this.currentStopId,
    this.nextStopId,
    this.driverLatitude,
    this.driverLongitude,
    this.lastDriverUpdate,
    this.currentPassengers,
    this.earnings,
    required this.createdAt,
    required this.updatedAt,
    this.route,
    this.vehicle,
    this.passengers,
  });

  bool get isActive => status == 'in_progress';
  bool get canStart => status == 'scheduled' || status == 'pending';
  bool get canEnd => status == 'in_progress';

  @override
  List<Object?> get props => [
    tripId,
    scheduleId,
    routeId,
    driverId,
    vehicleId,
    startTime,
    endTime,
    actualStartTime,
    actualEndTime,
    status,
    currentStopId,
    nextStopId,
    driverLatitude,
    driverLongitude,
    lastDriverUpdate,
    currentPassengers,
    earnings,
    createdAt,
    updatedAt,
    route,
    vehicle,
    passengers,
  ];
}

// lib/features/trip/domain/entities/trip_route.dart
class TripRoute extends Equatable {
  final int routeId;
  final String routeNumber;
  final String routeName;
  final String startPoint;
  final String endPoint;
  final double? distanceKm;
  final int? estimatedTimeMinutes;

  const TripRoute({
    required this.routeId,
    required this.routeNumber,
    required this.routeName,
    required this.startPoint,
    required this.endPoint,
    this.distanceKm,
    this.estimatedTimeMinutes,
  });

  @override
  List<Object?> get props => [
    routeId,
    routeNumber,
    routeName,
    startPoint,
    endPoint,
    distanceKm,
    estimatedTimeMinutes,
  ];
}

// lib/features/trip/domain/entities/trip_vehicle.dart
class TripVehicle extends Equatable {
  final int vehicleId;
  final String plateNumber;
  final String vehicleType;
  final String model;
  final int capacity;
  final String? color;
  final bool isAirConditioned;

  const TripVehicle({
    required this.vehicleId,
    required this.plateNumber,
    required this.vehicleType,
    required this.model,
    required this.capacity,
    this.color,
    required this.isAirConditioned,
  });

  @override
  List<Object?> get props => [
    vehicleId,
    plateNumber,
    vehicleType,
    model,
    capacity,
    color,
    isAirConditioned,
  ];
}

// lib/features/trip/domain/entities/trip_passenger.dart
class TripPassenger extends Equatable {
  final int bookingId;
  final String passengerName;
  final String passengerPhone;
  final int passengerCount;
  final String? seatNumbers;
  final String pickupStopName;
  final String dropoffStopName;
  final String status;
  final double fareAmount;
  final DateTime bookingTime;
  final DateTime? boardingTime;
  final DateTime? disembarkingTime;

  const TripPassenger({
    required this.bookingId,
    required this.passengerName,
    required this.passengerPhone,
    required this.passengerCount,
    this.seatNumbers,
    required this.pickupStopName,
    required this.dropoffStopName,
    required this.status,
    required this.fareAmount,
    required this.bookingTime,
    this.boardingTime,
    this.disembarkingTime,
  });

  bool get hasBoarded => status == 'boarded' || status == 'in_trip';
  bool get canBoard => status == 'confirmed' || status == 'paid';
  bool get canDisembark => status == 'boarded' || status == 'in_trip';

  @override
  List<Object?> get props => [
    bookingId,
    passengerName,
    passengerPhone,
    passengerCount,
    seatNumbers,
    pickupStopName,
    dropoffStopName,
    status,
    fareAmount,
    bookingTime,
    boardingTime,
    disembarkingTime,
  ];
}

// lib/features/trip/domain/entities/location_update.dart
class LocationUpdate extends Equatable {
  final double latitude;
  final double longitude;
  final double? speed;
  final double? heading;
  final DateTime timestamp;
  final int tripId;

  const LocationUpdate({
    required this.latitude,
    required this.longitude,
    this.speed,
    this.heading,
    required this.timestamp,
    required this.tripId,
  });

  @override
  List<Object?> get props => [
    latitude,
    longitude,
    speed,
    heading,
    timestamp,
    tripId,
  ];
}
