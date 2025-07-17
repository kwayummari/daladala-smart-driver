// lib/features/profile/domain/repositories/profile_repository.dart
import 'package:daladala_smart_driver/features/profile/domain/entities/profile.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class ProfileRepository {
  Future<Either<Failure, Profile>> getProfile();
  Future<Either<Failure, Profile>> updateProfile(
    Map<String, dynamic> profileData,
  );
}
