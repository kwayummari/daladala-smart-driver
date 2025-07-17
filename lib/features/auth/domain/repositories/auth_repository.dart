// lib/features/auth/domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/driver.dart';

abstract class AuthRepository {
  Future<Either<Failure, LoginResult>> login(String phone, String password);
  Future<Either<Failure, bool>> logout();
  Future<Either<Failure, Driver>> getProfile();
  Future<Either<Failure, bool>> updateDriverStatus(String status);
  Future<Either<Failure, bool>> isLoggedIn();
}
