// lib/features/auth/domain/entities/driver.dart
import 'package:equatable/equatable.dart';

class Driver extends Equatable {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? profilePicture;
  final String licenseNumber;
  final DateTime licenseExpiry;
  final String idNumber;
  final double rating;
  final int totalRatings;
  final bool isAvailable;
  final bool isTrackingEnabled;
  final String status;
  final DateTime? lastLocationUpdate;
  final double? currentLatitude;
  final double? currentLongitude;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Driver({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.profilePicture,
    required this.licenseNumber,
    required this.licenseExpiry,
    required this.idNumber,
    required this.rating,
    required this.totalRatings,
    required this.isAvailable,
    required this.isTrackingEnabled,
    required this.status,
    this.lastLocationUpdate,
    this.currentLatitude,
    this.currentLongitude,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  bool get isOnline => status == 'online' || status == 'active';

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    email,
    phone,
    profilePicture,
    licenseNumber,
    licenseExpiry,
    idNumber,
    rating,
    totalRatings,
    isAvailable,
    isTrackingEnabled,
    status,
    lastLocationUpdate,
    currentLatitude,
    currentLongitude,
    createdAt,
    updatedAt,
  ];
}

// lib/features/auth/domain/entities/driver_vehicle.dart
class DriverVehicle extends Equatable {
  final int vehicleId;
  final String plateNumber;
  final String vehicleType;
  final String model;
  final String? color;
  final int capacity;
  final bool isAirConditioned;
  final bool isActive;

  const DriverVehicle({
    required this.vehicleId,
    required this.plateNumber,
    required this.vehicleType,
    required this.model,
    this.color,
    required this.capacity,
    required this.isAirConditioned,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
    vehicleId,
    plateNumber,
    vehicleType,
    model,
    color,
    capacity,
    isAirConditioned,
    isActive,
  ];
}

// lib/features/auth/domain/entities/login_result.dart
class LoginResult extends Equatable {
  final Driver driver;
  final String token;
  final DriverVehicle? vehicle;

  const LoginResult({required this.driver, required this.token, this.vehicle});

  @override
  List<Object?> get props => [driver, token, vehicle];
}
