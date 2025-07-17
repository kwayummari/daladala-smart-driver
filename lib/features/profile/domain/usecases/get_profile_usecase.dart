// lib/features/profile/domain/usecases/get_profile_usecase.dart
import 'package:daladala_smart_driver/features/profile/data/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/profile.dart';

class GetProfileUseCase implements UseCase<Profile, NoParams> {
  final ProfileRepository repository;

  GetProfileUseCase(this.repository);

  @override
  Future<Either<Failure, Profile>> call(NoParams params) async {
    return await repository.getProfile();
  }
}
