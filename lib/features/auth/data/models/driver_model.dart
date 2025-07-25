import 'package:daladala_smart_driver/features/auth/domain/entities/driver_vehicle.dart';
import 'package:daladala_smart_driver/features/auth/domain/entities/login_result.dart';

import '../../domain/entities/driver.dart';

class DriverModel extends Driver {
  const DriverModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phone,
    super.profilePicture,
    required super.licenseNumber,
    required super.licenseExpiry,
    required super.idNumber,
    required super.rating,
    required super.totalRatings,
    required super.isAvailable,
    required super.isTrackingEnabled,
    required super.status,
    super.lastLocationUpdate,
    super.currentLatitude,
    super.currentLongitude,
    required super.createdAt,
    required super.updatedAt,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['User'] ?? {};
    return DriverModel(
      id: json['driver_id'] ?? json['id'],
      firstName: userJson['first_name'] ?? '',
      lastName: userJson['last_name'] ?? '',
      email: userJson['email'] ?? '',
      phone: userJson['phone'] ?? '',
      profilePicture: userJson['profile_picture'],
      licenseNumber: json['license_number'] ?? '',
      licenseExpiry: DateTime.parse(json['license_expiry']),
      idNumber: json['id_number'] ?? '',
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      totalRatings: json['total_ratings'] ?? 0,
      isAvailable: json['is_available'] ?? false,
      isTrackingEnabled: json['is_tracking_enabled'] ?? false,
      status: json['status'] ?? 'offline',
      lastLocationUpdate:
          json['last_location_update'] != null
              ? DateTime.parse(json['last_location_update'])
              : null,
      currentLatitude:
          json['current_latitude'] != null
              ? double.tryParse(json['current_latitude'].toString())
              : null,
      currentLongitude:
          json['current_longitude'] != null
              ? double.tryParse(json['current_longitude'].toString())
              : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'driver_id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'profile_picture': profilePicture,
      'license_number': licenseNumber,
      'license_expiry': licenseExpiry.toIso8601String(),
      'id_number': idNumber,
      'rating': rating,
      'total_ratings': totalRatings,
      'is_available': isAvailable,
      'is_tracking_enabled': isTrackingEnabled,
      'status': status,
      'last_location_update': lastLocationUpdate?.toIso8601String(),
      'current_latitude': currentLatitude,
      'current_longitude': currentLongitude,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class DriverVehicleModel extends DriverVehicle {
  const DriverVehicleModel({
    required super.vehicleId,
    required super.plateNumber,
    required super.vehicleType,
    required super.model,
    super.color,
    required super.capacity,
    required super.isAirConditioned,
    required super.isActive,
  });

  factory DriverVehicleModel.fromJson(Map<String, dynamic> json) {
    return DriverVehicleModel(
      vehicleId: json['vehicle_id'],
      plateNumber: json['plate_number'] ?? '',
      vehicleType: json['vehicle_type'] ?? '',
      model: json['model'] ?? '',
      color: json['color'],
      capacity: json['capacity'] ?? 0,
      isAirConditioned: json['is_air_conditioned'] ?? false,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicle_id': vehicleId,
      'plate_number': plateNumber,
      'vehicle_type': vehicleType,
      'model': model,
      'color': color,
      'capacity': capacity,
      'is_air_conditioned': isAirConditioned,
      'is_active': isActive,
    };
  }
}

class LoginResultModel extends LoginResult {
  const LoginResultModel({
    required super.driver,
    required super.token,
    super.vehicle,
  });

  factory LoginResultModel.fromJson(Map<String, dynamic> json) {
    return LoginResultModel(
      driver: DriverModel.fromJson(json['driver']),
      token: json['token'],
      vehicle:
          json['vehicle'] != null
              ? DriverVehicleModel.fromJson(json['vehicle'])
              : null,
    );
  }
}
