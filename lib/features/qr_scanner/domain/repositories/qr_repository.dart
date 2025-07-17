// lib/features/qr_scanner/domain/repositories/qr_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/qr_validation_result.dart';

abstract class QRRepository {
  Future<Either<Failure, QRValidationResult>> validateQRCode(String qrData);
}
