import 'package:equatable/equatable.dart';

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