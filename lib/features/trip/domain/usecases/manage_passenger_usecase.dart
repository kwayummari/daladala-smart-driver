// lib/features/trip/domain/usecases/manage_passenger_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/trip_repository.dart';

class MarkPassengerBoardedUseCase
    implements UseCase<bool, PassengerActionParams> {
  final TripRepository repository;

  MarkPassengerBoardedUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(PassengerActionParams params) async {
    return await repository.markPassengerBoarded(params.bookingId);
  }
}

class MarkPassengerDisembarkedUseCase
    implements UseCase<bool, PassengerActionParams> {
  final TripRepository repository;

  MarkPassengerDisembarkedUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(PassengerActionParams params) async {
    return await repository.markPassengerDisembarked(params.bookingId);
  }
}

class PassengerActionParams {
  final int bookingId;

  PassengerActionParams({required this.bookingId});
}
