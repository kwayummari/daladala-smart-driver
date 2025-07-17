// lib/features/qr_scanner/presentation/providers/qr_provider.dart
import 'package:daladala_smart_driver/features/qr_scanner/domain/usecases/validate_qr_usecase.dart';
import 'package:flutter/material.dart';
import '../../../../core/services/qr_service.dart';
import '../../domain/entities/qr_validation_result.dart';

enum QRScanState { initial, scanning, validating, success, error }

class QRProvider extends ChangeNotifier {
  final ValidateQRUseCase validateQRUseCase;
  final QRService qrService;

  QRProvider({required this.validateQRUseCase, required this.qrService});

  QRScanState _state = QRScanState.initial;
  QRValidationResult? _validationResult;
  String? _errorMessage;
  bool _isScanning = false;

  // Getters
  QRScanState get state => _state;
  QRValidationResult? get validationResult => _validationResult;
  String? get errorMessage => _errorMessage;
  bool get isScanning => _isScanning;

  // Start scanning
  void startScanning() {
    _state = QRScanState.scanning;
    _isScanning = true;
    _validationResult = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Stop scanning
  void stopScanning() {
    _state = QRScanState.initial;
    _isScanning = false;
    notifyListeners();
  }

  // Validate QR code
  Future<void> validateQRCode(String qrData) async {
    try {
      _state = QRScanState.validating;
      _isScanning = false;
      _errorMessage = null;
      notifyListeners();

      // Parse QR data locally first
      final parsedData = qrService.parseQRData(qrData);

      if (parsedData == null) {
        _setError('Invalid QR code format');
        await qrService.playScanError();
        return;
      }

      // Validate with server
      final result = await validateQRUseCase(ValidateQRParams(qrData: qrData));

      result.fold(
        (failure) {
          _setError(failure.message);
          qrService.playScanError();
        },
        (validationResult) {
          _validationResult = validationResult;
          if (validationResult.isValid) {
            _state = QRScanState.success;
            qrService.playScanSuccess();
          } else {
            _setError(validationResult.message);
            qrService.playScanError();
          }
        },
      );
    } catch (e) {
      _setError('Failed to validate QR code: $e');
      await qrService.playScanError();
    } finally {
      notifyListeners();
    }
  }

  // Reset state
  void reset() {
    _state = QRScanState.initial;
    _validationResult = null;
    _errorMessage = null;
    _isScanning = false;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    if (_state == QRScanState.error) {
      _state = QRScanState.initial;
    }
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _state = QRScanState.error;
    _isScanning = false;
  }
}
