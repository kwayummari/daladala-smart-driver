import 'package:equatable/equatable.dart';

class Driver extends Equatable {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? profilePicture;
  final String licenseNumber;
  final DateTime licenseExpiry;
  final String idNumber;
  final double rating;
  final int totalRatings;
  final bool isAvailable;
  final bool isTrackingEnabled;
  final String status;
  final DateTime? lastLocationUpdate;
  final double? currentLatitude;
  final double? currentLongitude;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Driver({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.profilePicture,
    required this.licenseNumber,
    required this.licenseExpiry,
    required this.idNumber,
    required this.rating,
    required this.totalRatings,
    required this.isAvailable,
    required this.isTrackingEnabled,
    required this.status,
    this.lastLocationUpdate,
    this.currentLatitude,
    this.currentLongitude,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  bool get isOnline => status == 'online' || status == 'active';

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    email,
    phone,
    profilePicture,
    licenseNumber,
    licenseExpiry,
    idNumber,
    rating,
    totalRatings,
    isAvailable,
    isTrackingEnabled,
    status,
    lastLocationUpdate,
    currentLatitude,
    currentLongitude,
    createdAt,
    updatedAt,
  ];
}