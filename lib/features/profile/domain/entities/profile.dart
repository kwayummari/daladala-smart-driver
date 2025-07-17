// lib/features/profile/domain/entities/profile.dart
import 'package:equatable/equatable.dart';

class Profile extends Equatable {
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
  final DateTime createdAt;
  final DateTime updatedAt;

  const Profile({
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
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

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
        createdAt,
        updatedAt,
      ];
}

