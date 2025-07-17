// lib/features/qr_scanner/domain/usecases/validate_qr_usecase.dart
import 'package:daladala_smart_driver/features/qr_scanner/domain/repositories/qr_repository.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/qr_validation_result.dart';

class ValidateQRUseCase
    implements UseCase<QRValidationResult, ValidateQRParams> {
  final QRRepository repository;

  ValidateQRUseCase(this.repository);

  @override
  Future<Either<Failure, QRValidationResult>> call(
    ValidateQRParams params,
  ) async {
    return await repository.validateQRCode(params.qrData);
  }
}

class ValidateQRParams {
  final String qrData;

  ValidateQRParams({required this.qrData});
}
