import 'package:daladala_smart_driver/features/auth/domain/entities/driver.dart';
import 'package:daladala_smart_driver/features/auth/domain/entities/driver_vehicle.dart';
import 'package:equatable/equatable.dart';

class LoginResult extends Equatable {
  final Driver driver;
  final String token;
  final DriverVehicle? vehicle;

  const LoginResult({required this.driver, required this.token, this.vehicle});

  @override
  List<Object?> get props => [driver, token, vehicle];
}
