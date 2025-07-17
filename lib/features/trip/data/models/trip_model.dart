// lib/features/trip/data/models/trip_model.dart
import '../../domain/entities/trip.dart';

class TripModel extends Trip {
  const TripModel({
    required super.tripId,
    required super.scheduleId,
    required super.routeId,
    super.driverId,
    super.vehicleId,
    required super.startTime,
    super.endTime,
    super.actualStartTime,
    super.actualEndTime,
    required super.status,
    super.currentStopId,
    super.nextStopId,
    super.driverLatitude,
    super.driverLongitude,
    super.lastDriverUpdate,
    super.currentPassengers,
    super.earnings,
    required super.createdAt,
    required super.updatedAt,
    super.route,
    super.vehicle,
    super.passengers,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      tripId: json['trip_id'],
      scheduleId: json['schedule_id'],
      routeId: json['route_id'],
      driverId: json['driver_id'],
      vehicleId: json['vehicle_id'],
      startTime: DateTime.parse(json['start_time']),
      endTime:
          json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      actualStartTime:
          json['actual_start_time'] != null
              ? DateTime.parse(json['actual_start_time'])
              : null,
      actualEndTime:
          json['actual_end_time'] != null
              ? DateTime.parse(json['actual_end_time'])
              : null,
      status: json['status'] ?? 'pending',
      currentStopId: json['current_stop_id'],
      nextStopId: json['next_stop_id'],
      driverLatitude:
          double.tryParse(json['driver_latitude']?.toString() ?? '0') ?? 0.0,
      driverLongitude:
          double.tryParse(json['driver_longitude']?.toString() ?? '0') ?? 0.0,
      lastDriverUpdate:
          json['last_driver_update'] != null
              ? DateTime.parse(json['last_driver_update'])
              : null,
      currentPassengers: json['current_passengers'],
      earnings: double.tryParse(json['earnings']?.toString() ?? '0') ?? 0.0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      route:
          json['Route'] != null || json['route'] != null
              ? TripRouteModel.fromJson(json['Route'] ?? json['route'])
              : null,
      vehicle:
          json['Vehicle'] != null || json['vehicle'] != null
              ? TripVehicleModel.fromJson(json['Vehicle'] ?? json['vehicle'])
              : null,
      passengers:
          json['passengers'] != null
              ? (json['passengers'] as List)
                  .map((p) => TripPassengerModel.fromJson(p))
                  .toList()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trip_id': tripId,
      'schedule_id': scheduleId,
      'route_id': routeId,
      'driver_id': driverId,
      'vehicle_id': vehicleId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'actual_start_time': actualStartTime?.toIso8601String(),
      'actual_end_time': actualEndTime?.toIso8601String(),
      'status': status,
      'current_stop_id': currentStopId,
      'next_stop_id': nextStopId,
      'driver_latitude': driverLatitude,
      'driver_longitude': driverLongitude,
      'last_driver_update': lastDriverUpdate?.toIso8601String(),
      'current_passengers': currentPassengers,
      'earnings': earnings,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class TripRouteModel extends TripRoute {
  const TripRouteModel({
    required super.routeId,
    required super.routeNumber,
    required super.routeName,
    required super.startPoint,
    required super.endPoint,
    super.distanceKm,
    super.estimatedTimeMinutes,
  });

  factory TripRouteModel.fromJson(Map<String, dynamic> json) {
    return TripRouteModel(
      routeId: json['route_id'],
      routeNumber: json['route_number'] ?? '',
      routeName: json['route_name'] ?? '',
      startPoint: json['start_point'] ?? '',
      endPoint: json['end_point'] ?? '',
      distanceKm:
          double.tryParse(json['distance_km']?.toString() ?? '0') ?? 0.0,
      estimatedTimeMinutes: json['estimated_time_minutes'],
    );
  }
}

class TripVehicleModel extends TripVehicle {
  const TripVehicleModel({
    required super.vehicleId,
    required super.plateNumber,
    required super.vehicleType,
    required super.model,
    required super.capacity,
    super.color,
    required super.isAirConditioned,
  });

  factory TripVehicleModel.fromJson(Map<String, dynamic> json) {
    return TripVehicleModel(
      vehicleId: json['vehicle_id'],
      plateNumber: json['plate_number'] ?? '',
      vehicleType: json['vehicle_type'] ?? '',
      model: json['model'] ?? '',
      capacity: json['capacity'] ?? 0,
      color: json['color'],
      isAirConditioned: json['is_air_conditioned'] ?? false,
    );
  }
}

class TripPassengerModel extends TripPassenger {
  const TripPassengerModel({
    required super.bookingId,
    required super.passengerName,
    required super.passengerPhone,
    required super.passengerCount,
    super.seatNumbers,
    required super.pickupStopName,
    required super.dropoffStopName,
    required super.status,
    required super.fareAmount,
    required super.bookingTime,
    super.boardingTime,
    super.disembarkingTime,
  });

  factory TripPassengerModel.fromJson(Map<String, dynamic> json) {
    return TripPassengerModel(
      bookingId: json['booking_id'],
      passengerName:
          json['passenger_name'] ??
          '${json['user']?['first_name'] ?? ''} ${json['user']?['last_name'] ?? ''}',
      passengerPhone: json['passenger_phone'] ?? json['user']?['phone'] ?? '',
      passengerCount: json['passenger_count'] ?? 1,
      seatNumbers: json['seat_numbers'],
      pickupStopName:
          json['pickup_stop_name'] ?? json['pickup_stop']?['stop_name'] ?? '',
      dropoffStopName:
          json['dropoff_stop_name'] ?? json['dropoff_stop']?['stop_name'] ?? '',
      status: json['status'] ?? 'pending',
      fareAmount:
          double.tryParse(json['fare_amount']?.toString() ?? '0') ?? 0.0,
      bookingTime: DateTime.parse(json['booking_time'] ?? json['created_at']),
      boardingTime:
          json['boarding_time'] != null
              ? DateTime.parse(json['boarding_time'])
              : null,
      disembarkingTime:
          json['disembarking_time'] != null
              ? DateTime.parse(json['disembarking_time'])
              : null,
    );
  }
}
