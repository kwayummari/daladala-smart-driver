// lib/features/auth/domain/usecases/get_profile_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/driver.dart';
import '../repositories/auth_repository.dart';

class GetProfileUseCase implements UseCase<Driver, NoParams> {
  final AuthRepository repository;

  GetProfileUseCase(this.repository);

  @override
  Future<Either<Failure, Driver>> call(NoParams params) async {
    return await repository.getProfile();
  }
}
