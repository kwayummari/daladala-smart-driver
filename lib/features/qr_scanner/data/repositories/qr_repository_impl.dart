// lib/features/qr_scanner/data/repositories/qr_repository_impl.dart
import 'package:daladala_smart_driver/core/usecases/usecase.dart';
import 'package:daladala_smart_driver/features/qr_scanner/data/datasources/qr_datasource.dart';
import 'package:daladala_smart_driver/features/qr_scanner/domain/repositories/qr_repository.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/qr_validation_result.dart';

class QRRepositoryImpl implements QRRepository {
  final QRDataSource dataSource;

  QRRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, QRValidationResult>> validateQRCode(
    String qrData,
  ) async {
    try {
      final result = await dataSource.validateQRCode(qrData);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
