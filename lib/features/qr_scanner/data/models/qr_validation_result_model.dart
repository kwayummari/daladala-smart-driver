// lib/features/qr_scanner/data/models/qr_validation_result_model.dart
import '../../domain/entities/qr_validation_result.dart';

class QRValidationResultModel extends QRValidationResult {
  const QRValidationResultModel({
    required super.isValid,
    required super.message,
    super.bookingId,
    super.passengerName,
    super.passengerPhone,
    super.passengerCount,
    super.seatNumbers,
    super.pickupStop,
    super.dropoffStop,
    super.routeName,
    super.fareAmount,
    super.expiresAt,
  });

  factory QRValidationResultModel.fromJson(Map<String, dynamic> json) {
    final bookingData = json['booking_details'];

    return QRValidationResultModel(
      isValid: json['valid'] ?? false,
      message: json['message'] ?? '',
      bookingId: bookingData?['booking_id'],
      passengerName: bookingData?['passenger_name'],
      passengerPhone: bookingData?['passenger_phone'],
      passengerCount: bookingData?['passenger_count'],
      seatNumbers: bookingData?['seat_numbers'],
      pickupStop: bookingData?['pickup_stop'],
      dropoffStop: bookingData?['dropoff_stop'],
      routeName: bookingData?['route_name'],
      fareAmount: double.tryParse(bookingData?['fare_amount']?.toString() ?? '0') ?? 0.0,
      expiresAt:
          bookingData?['expires_at'] != null
              ? DateTime.parse(bookingData['expires_at'])
              : null,
    );
  }
}
