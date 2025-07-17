
// lib/features/qr_scanner/presentation/pages/qr_scanner_page.dart
import 'package:daladala_smart_driver/features/qr_scanner/presentation/providers/qr_provider.dart';
import 'package:daladala_smart_driver/features/qr_scanner/presentation/widgets/qr_scanner_overlay.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/widgets/custom_button.dart';
import '../widgets/qr_validation_result_card.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final qrProvider = Provider.of<QRProvider>(context, listen: false);
      qrProvider.reset();
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null) {
        _onQRCodeScanned(scanData.code!);
      }
    });
  }

  void _onQRCodeScanned(String qrData) {
    final qrProvider = Provider.of<QRProvider>(context, listen: false);
    
    // Pause scanning while validating
    controller?.pauseCamera();
    qrProvider.validateQRCode(qrData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Scan Passenger QR'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _toggleFlash,
            icon: Icon(
              _isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Consumer<QRProvider>(
        builder: (context, qrProvider, child) {
          return Stack(
            children: [
              // QR Scanner View
              if (qrProvider.state != QRScanState.success &&
                  qrProvider.state != QRScanState.error) ...[
                Expanded(
                  child: QRView(
                    key: qrKey,
                    onQRViewCreated: _onQRViewCreated,
                    overlay: QrScannerOverlayShape(
                      borderColor: AppTheme.primaryColor,
                      borderRadius: 10,
                      borderLength: 30,
                      borderWidth: 10,
                      cutOutSize: 250,
                    ),
                  ),
                ),
                
                // Scanner Overlay
                const QRScannerOverlay(),
              ],

              // Validation Result
              if (qrProvider.state == QRScanState.success ||
                  qrProvider.state == QRScanState.error) ...[
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black.withOpacity(0.8),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          QRValidationResultCard(
                            result: qrProvider.validationResult,
                            error: qrProvider.errorMessage,
                          ),
                          
                          const SizedBox(height: 24),
                          
                          Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                  text: 'Scan Again',
                                  onPressed: _scanAgain,
                                  type: ButtonType.secondary,
                                  backgroundColor: Colors.white,
                                  textColor: AppTheme.primaryColor,
                                  borderColor: Colors.white,
                                ),
                              ),
                              if (qrProvider.state == QRScanState.success) ...[
                                const SizedBox(width: 12),
                                Expanded(
                                  child: CustomButton(
                                    text: 'Mark Boarded',
                                    onPressed: () => _markPassengerBoarded(context),
                                    type: ButtonType.primary,
                                    backgroundColor: AppTheme.successColor,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              // Loading Overlay
              if (qrProvider.state == QRScanState.validating) ...[
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black.withOpacity(0.8),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Validating QR Code...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  void _toggleFlash() async {
    if (controller != null) {
      await controller!.toggleFlash();
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    }
  }

  void _scanAgain() {
    final qrProvider = Provider.of<QRProvider>(context, listen: false);
    qrProvider.reset();
    controller?.resumeCamera();
  }

  void _markPassengerBoarded(BuildContext context) {
    final qrProvider = Provider.of<QRProvider>(context, listen: false);
    final result = qrProvider.validationResult;
    
    if (result != null && result.bookingId != null) {
      // Navigate back or show success message
      Navigator.pop(context, {
        'action': 'board_passenger',
        'booking_id': result.bookingId,
        'passenger_name': result.passengerName,
      });
    }
  }
}
