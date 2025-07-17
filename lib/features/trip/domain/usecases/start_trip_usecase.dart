// lib/features/trip/domain/usecases/start_trip_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/trip_repository.dart';

class StartTripUseCase implements UseCase<bool, StartTripParams> {
  final TripRepository repository;

  StartTripUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(StartTripParams params) async {
    return await repository.startTrip(params.tripId);
  }
}

class StartTripParams {
  final int tripId;

  StartTripParams({required this.tripId});
}
