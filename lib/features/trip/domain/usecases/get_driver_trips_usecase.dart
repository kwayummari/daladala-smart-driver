// lib/features/trip/domain/usecases/get_driver_trips_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/trip.dart';
import '../repositories/trip_repository.dart';

class GetDriverTripsUseCase
    implements UseCase<List<Trip>, GetDriverTripsParams> {
  final TripRepository repository;

  GetDriverTripsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Trip>>> call(GetDriverTripsParams params) async {
    return await repository.getDriverTrips(
      status: params.status,
      date: params.date,
      page: params.page,
      limit: params.limit,
    );
  }
}

class GetDriverTripsParams {
  final String? status;
  final String? date;
  final int page;
  final int limit;

  GetDriverTripsParams({
    this.status,
    this.date,
    this.page = 1,
    this.limit = 20,
  });
}
