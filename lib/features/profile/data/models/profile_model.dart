// lib/features/profile/data/models/profile_model.dart
import '../../domain/entities/profile.dart';

class ProfileModel extends Profile {
  const ProfileModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phone,
    super.profilePicture,
    required super.licenseNumber,
    required super.licenseExpiry,
    required super.idNumber,
    required super.rating,
    required super.totalRatings,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['driver_id'] ?? json['id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profilePicture: json['profile_picture'],
      licenseNumber: json['license_number'] ?? '',
      licenseExpiry: DateTime.parse(json['license_expiry']),
      idNumber: json['id_number'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalRatings: json['total_ratings'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'driver_id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'profile_picture': profilePicture,
      'license_number': licenseNumber,
      'license_expiry': licenseExpiry.toIso8601String(),
      'id_number': idNumber,
      'rating': rating,
      'total_ratings': totalRatings,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
