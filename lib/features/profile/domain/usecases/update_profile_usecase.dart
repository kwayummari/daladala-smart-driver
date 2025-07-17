// lib/features/profile/domain/usecases/update_profile_usecase.dart
import 'package:daladala_smart_driver/features/profile/data/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/profile.dart';

class UpdateProfileUseCase implements UseCase<Profile, UpdateProfileParams> {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, Profile>> call(UpdateProfileParams params) async {
    return await repository.updateProfile(params.profileData);
  }
}

class UpdateProfileParams {
  final Map<String, dynamic> profileData;

  UpdateProfileParams({required this.profileData});
}
