import 'package:daladala_smart_driver/core/error/failures.dart';
import 'package:daladala_smart_driver/core/usecases/usecase.dart';
import 'package:daladala_smart_driver/features/auth/data/datasources/auth_datasource.dart';
import 'package:daladala_smart_driver/features/auth/domain/entities/driver.dart';
import 'package:daladala_smart_driver/features/auth/domain/entities/driver_vehicle.dart';
import 'package:daladala_smart_driver/features/auth/domain/entities/login_result.dart';
import 'package:daladala_smart_driver/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource dataSource;

  AuthRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, LoginResult>> login(
    String phone,
    String password,
  ) async {
    try {
      final result = await dataSource.login(phone, password);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final result = await dataSource.logout();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Driver>> getProfile() async {
    try {
      final result = await dataSource.getProfile();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateDriverStatus(String status) async {
    try {
      final result = await dataSource.updateDriverStatus(status);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final result = await dataSource.isLoggedIn();
      return Right(result);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> changePassword(String oldPassword, String newPassword) {
    // TODO: implement changePassword
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> deleteAccount() {
    // TODO: implement deleteAccount
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, DriverVehicle?>> getDriverVehicle() {
    // TODO: implement getDriverVehicle
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> resendVerificationCode(String phone) {
    // TODO: implement resendVerificationCode
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> resetPassword(String phone, String newPassword) {
    // TODO: implement resetPassword
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> updateDriverAvailability(bool isAvailable) {
    // TODO: implement updateDriverAvailability
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> updateDriverLocation(double latitude, double longitude) {
    // TODO: implement updateDriverLocation
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> updateDriverProfile(Driver driver) {
    // TODO: implement updateDriverProfile
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> updateDriverRating(double rating) {
    // TODO: implement updateDriverRating
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> updateDriverTotalRatings(int totalRatings) {
    // TODO: implement updateDriverTotalRatings
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> updateDriverTracking(bool isEnabled) {
    // TODO: implement updateDriverTracking
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> updateDriverVehicle(DriverVehicle vehicle) {
    // TODO: implement updateDriverVehicle
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> updateNotificationToken(String token) {
    // TODO: implement updateNotificationToken
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> verifyPhone(String phone, String code) {
    // TODO: implement verifyPhone
    throw UnimplementedError();
  }
}
