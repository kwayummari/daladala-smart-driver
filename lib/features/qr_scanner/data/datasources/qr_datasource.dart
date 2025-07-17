// lib/features/qr_scanner/data/datasources/qr_datasource.dart
import 'package:daladala_smart_driver/core/usecases/usecase.dart';
import 'package:daladala_smart_driver/features/qr_scanner/data/models/qr_validation_result_model.dart';

import '../../../../core/services/api_service.dart';

abstract class QRDataSource {
  Future<QRValidationResultModel> validateQRCode(String qrData);
}

class QRDataSourceImpl implements QRDataSource {
  final ApiService apiService;

  QRDataSourceImpl(this.apiService);

  @override
  Future<QRValidationResultModel> validateQRCode(String qrData) async {
    try {
      final response = await apiService.validateBookingQR(qrData);

      if (response['status'] == 'success' || response['valid'] == true) {
        return QRValidationResultModel.fromJson(response);
      } else {
        return QRValidationResultModel(
          isValid: false,
          message: response['message'] ?? 'Invalid QR code',
        );
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
