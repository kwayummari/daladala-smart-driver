// lib/features/trip/domain/usecases/get_trip_passengers_usecase.dart
import 'package:daladala_smart_driver/features/trip/domain/entities/trip.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/trip_repository.dart';

class GetTripPassengersUseCase
    implements UseCase<List<TripPassenger>, GetTripPassengersParams> {
  final TripRepository repository;

  GetTripPassengersUseCase(this.repository);

  @override
  Future<Either<Failure, List<TripPassenger>>> call(
    GetTripPassengersParams params,
  ) async {
    return await repository.getTripPassengers(params.tripId);
  }
}

class GetTripPassengersParams {
  final int tripId;

  GetTripPassengersParams({required this.tripId});
}
