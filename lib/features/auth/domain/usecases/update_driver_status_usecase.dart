// lib/features/auth/domain/usecases/update_driver_status_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class UpdateDriverStatusUseCase
    implements UseCase<bool, UpdateDriverStatusParams> {
  final AuthRepository repository;

  UpdateDriverStatusUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(UpdateDriverStatusParams params) async {
    return await repository.updateDriverStatus(params.status);
  }
}

class UpdateDriverStatusParams {
  final String status;

  UpdateDriverStatusParams({required this.status});
}
