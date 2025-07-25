import 'package:daladala_smart_driver/features/auth/domain/entities/driver_vehicle.dart';
import 'package:daladala_smart_driver/features/auth/domain/entities/login_result.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/driver.dart';

abstract class AuthRepository {
  Future<Either<Failure, LoginResult>> login(String phone, String password);
  Future<Either<Failure, bool>> logout();
  Future<Either<Failure, Driver>> getProfile();
  Future<Either<Failure, bool>> updateDriverStatus(String status);
  Future<Either<Failure, bool>> isLoggedIn();
  Future<Either<Failure, DriverVehicle?>> getDriverVehicle();
  Future<Either<Failure, bool>> updateDriverVehicle(DriverVehicle vehicle);
  Future<Either<Failure, bool>> updateDriverProfile(Driver driver);
  Future<Either<Failure, bool>> updateDriverLocation(double latitude, double longitude);
  Future<Either<Failure, bool>> updateDriverTracking(bool isEnabled);
  Future<Either<Failure, bool>> updateDriverAvailability(bool isAvailable);
  Future<Either<Failure, bool>> changePassword(String oldPassword, String newPassword);
  Future<Either<Failure, bool>> resetPassword(String phone, String newPassword);
  Future<Either<Failure, bool>> verifyPhone(String phone, String code);
  Future<Either<Failure, bool>> resendVerificationCode(String phone);
  Future<Either<Failure, bool>> deleteAccount();
  Future<Either<Failure, bool>> updateNotificationToken(String token);
  Future<Either<Failure, bool>> updateDriverRating(double rating);
  Future<Either<Failure, bool>> updateDriverTotalRatings(int totalRatings);
}
