// lib/features/trip/domain/repositories/trip_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/trip.dart';

abstract class TripRepository {
  Future<Either<Failure, List<Trip>>> getDriverTrips({
    String? status,
    String? date,
    int page = 1,
    int limit = 20,
  });
  
  Future<Either<Failure, Trip>> getTripDetails(int tripId);
  Future<Either<Failure, bool>> startTrip(int tripId);
  Future<Either<Failure, bool>> endTrip(int tripId);
  
  Future<Either<Failure, bool>> updateLocation(LocationUpdate locationUpdate);
  Future<Either<Failure, List<TripPassenger>>> getTripPassengers(int tripId);
  
  Future<Either<Failure, bool>> markPassengerBoarded(int bookingId);
  Future<Either<Failure, bool>> markPassengerDisembarked(int bookingId);
}

