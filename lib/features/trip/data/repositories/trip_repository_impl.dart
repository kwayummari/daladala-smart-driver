// lib/features/trip/data/repositories/trip_repository_impl.dart
import 'package:daladala_smart_driver/core/usecases/usecase.dart';
import 'package:daladala_smart_driver/features/trip/data/datasources/trip_datasource.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/trip.dart';
import '../../domain/repositories/trip_repository.dart';

class TripRepositoryImpl implements TripRepository {
  final TripDataSource dataSource;

  TripRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<Trip>>> getDriverTrips({
    String? status,
    String? date,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final result = await dataSource.getDriverTrips(
        status: status,
        date: date,
        page: page,
        limit: limit,
      );
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
  Future<Either<Failure, Trip>> getTripDetails(int tripId) async {
    try {
      final result = await dataSource.getTripDetails(tripId);
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
  Future<Either<Failure, bool>> startTrip(int tripId) async {
    try {
      final result = await dataSource.startTrip(tripId);
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
  Future<Either<Failure, bool>> endTrip(int tripId) async {
    try {
      final result = await dataSource.endTrip(tripId);
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
  Future<Either<Failure, bool>> updateLocation(
    LocationUpdate locationUpdate,
  ) async {
    try {
      final result = await dataSource.updateLocation(
        tripId: locationUpdate.tripId,
        latitude: locationUpdate.latitude,
        longitude: locationUpdate.longitude,
        speed: locationUpdate.speed,
        heading: locationUpdate.heading,
      );
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
  Future<Either<Failure, List<TripPassenger>>> getTripPassengers(
    int tripId,
  ) async {
    try {
      final result = await dataSource.getTripPassengers(tripId);
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
  Future<Either<Failure, bool>> markPassengerBoarded(int bookingId) async {
    try {
      final result = await dataSource.markPassengerBoarded(bookingId);
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
  Future<Either<Failure, bool>> markPassengerDisembarked(int bookingId) async {
    try {
      final result = await dataSource.markPassengerDisembarked(bookingId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
