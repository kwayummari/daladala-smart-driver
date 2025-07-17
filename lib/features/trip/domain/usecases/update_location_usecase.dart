// lib/features/trip/domain/usecases/update_location_usecase.dart
import 'package:daladala_smart_driver/features/trip/domain/entities/trip.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/trip_repository.dart';

class UpdateLocationUseCase implements UseCase<bool, UpdateLocationParams> {
  final TripRepository repository;

  UpdateLocationUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(UpdateLocationParams params) async {
    return await repository.updateLocation(params.locationUpdate);
  }
}

class UpdateLocationParams {
  final LocationUpdate locationUpdate;

  UpdateLocationParams({required this.locationUpdate});
}
