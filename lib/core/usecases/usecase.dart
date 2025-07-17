// lib/core/usecases/usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../error/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}

// lib/core/error/exceptions.dart
class ServerException implements Exception {
  final String message;

  const ServerException(this.message);
}

class NetworkException implements Exception {
  final String message;

  const NetworkException(this.message);
}

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);
}

class ValidationException implements Exception {
  final String message;

  const ValidationException(this.message);
}

class CacheException implements Exception {
  final String message;

  const CacheException(this.message);
}

class LocationException implements Exception {
  final String message;

  const LocationException(this.message);
}

class CameraException implements Exception {
  final String message;

  const CameraException(this.message);
}
