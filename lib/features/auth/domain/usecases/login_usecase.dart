// lib/features/auth/domain/usecases/login_usecase.dart
import 'package:daladala_smart_driver/features/auth/domain/entities/driver.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase implements UseCase<LoginResult, LoginParams> {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, LoginResult>> call(LoginParams params) async {
    return await repository.login(params.phone, params.password);
  }
}

class LoginParams {
  final String phone;
  final String password;

  LoginParams({required this.phone, required this.password});
}
