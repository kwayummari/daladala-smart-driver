// lib/core/utils/validators.dart
class Validators {
  static String? validateRequired(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    // Remove spaces and dashes
    final cleanPhone = value.replaceAll(RegExp(r'[\s-]'), '');

    // Check if it's a valid Tanzanian phone number
    if (!RegExp(r'^(\+255|0)[67]\d{8}$').hasMatch(cleanPhone)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  String? validateLicenseNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'License number is required';
    }

    if (value.length < 8) {
      return 'License number must be at least 8 characters';
    }

    return null;
  }

  String? validatePlateNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Plate number is required';
    }

    // Basic Tanzania plate number validation
    if (!RegExp(
      r'^[A-Z]{1,3}\s?\d{3,4}\s?[A-Z]{1,3}',
      caseSensitive: false,
    ).hasMatch(value)) {
      return 'Please enter a valid plate number';
    }

    return null;
  }
}
