// lib/features/trip/domain/usecases/end_trip_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/trip_repository.dart';

class EndTripUseCase implements UseCase<bool, EndTripParams> {
  final TripRepository repository;

  EndTripUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(EndTripParams params) async {
    return await repository.endTrip(params.tripId);
  }
}

class EndTripParams {
  final int tripId;

  EndTripParams({required this.tripId});
}
