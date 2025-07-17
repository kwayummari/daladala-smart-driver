// lib/features/qr_scanner/domain/entities/qr_validation_result.dart
import 'package:equatable/equatable.dart';

class QRValidationResult extends Equatable {
  final bool isValid;
  final String message;
  final int? bookingId;
  final String? passengerName;
  final String? passengerPhone;
  final int? passengerCount;
  final String? seatNumbers;
  final String? pickupStop;
  final String? dropoffStop;
  final String? routeName;
  final double? fareAmount;
  final DateTime? expiresAt;

  const QRValidationResult({
    required this.isValid,
    required this.message,
    this.bookingId,
    this.passengerName,
    this.passengerPhone,
    this.passengerCount,
    this.seatNumbers,
    this.pickupStop,
    this.dropoffStop,
    this.routeName,
    this.fareAmount,
    this.expiresAt,
  });

  @override
  List<Object?> get props => [
        isValid,
        message,
        bookingId,
        passengerName,
        passengerPhone,
        passengerCount,
        seatNumbers,
        pickupStop,
        dropoffStop,
        routeName,
        fareAmount,
        expiresAt,
      ];
}
