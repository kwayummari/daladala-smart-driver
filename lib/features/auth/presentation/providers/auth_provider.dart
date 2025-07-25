import 'package:daladala_smart_driver/core/services/api_service.dart';
import 'package:daladala_smart_driver/features/auth/domain/entities/driver_vehicle.dart';
import 'package:flutter/material.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/driver.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_driver_status_usecase.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final GetProfileUseCase getProfileUseCase;
  final UpdateDriverStatusUseCase updateDriverStatusUseCase;
  final ApiService apiService;

  AuthProvider({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.getProfileUseCase,
    required this.updateDriverStatusUseCase,
    required this.apiService,
  });

  AuthState _state = AuthState.initial;
  Driver? _driver;
  String? _errorMessage;
  bool _isLoading = false;
  DriverVehicle? _vehicle;

  // Getters
  AuthState get state => _state;
  Driver? get driver => _driver;
  DriverVehicle? get vehicle => _vehicle;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated =>
      _state == AuthState.authenticated && _driver != null;


  Future<bool> registerDriver(Map<String, dynamic> registrationData) async {
    try {
      _setLoading(true);
      _clearError();

      // Use apiService directly instead of use case
      final response = await apiService.driverRegister(registrationData);

      if (response['status'] == 'success') {
        return true;
      } else {
        _setError(response['message'] ?? 'Registration failed');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateDriverAvailability(bool isAvailable) async {
    try {
      _setLoading(true);

      final status = isAvailable ? 'online' : 'offline';
      final result = await updateDriverStatusUseCase(
        UpdateDriverStatusParams(status: status),
      );

      return result.fold(
        (failure) {
          _setError(failure.message);
          return false;
        },
        (success) {
          if (_driver != null) {
            // Replace copyWith with new Driver instance
            _driver = Driver(
              id: _driver!.id,
              firstName: _driver!.firstName,
              lastName: _driver!.lastName,
              email: _driver!.email,
              phone: _driver!.phone,
              profilePicture: _driver!.profilePicture,
              licenseNumber: _driver!.licenseNumber,
              licenseExpiry: _driver!.licenseExpiry,
              idNumber: _driver!.idNumber,
              rating: _driver!.rating,
              totalRatings: _driver!.totalRatings,
              isAvailable: isAvailable, // Updated value
              isTrackingEnabled: _driver!.isTrackingEnabled,
              status: status, // Updated value
              lastLocationUpdate: DateTime.now(),
              currentLatitude: _driver!.currentLatitude,
              currentLongitude: _driver!.currentLongitude,
              createdAt: _driver!.createdAt,
              updatedAt: DateTime.now(),
            );
            notifyListeners();
          }
          return true;
        },
      );
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>?> getDriverStatistics({
    String? startDate,
    String? endDate,
  }) async {
    try {
      _setLoading(true);

      final response = await apiService.getDriverStatistics(
        startDate: startDate,
        endDate: endDate,
      );

      if (response['status'] == 'success') {
        return response['data'];
      } else {
        _setError(response['message'] ?? 'Failed to load statistics');
        return null;
      }
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>?> getDriverEarnings({
    String? startDate,
    String? endDate,
    String period = 'daily',
  }) async {
    try {
      _setLoading(true);

      final response = await apiService.getDriverEarnings(
        startDate: startDate,
        endDate: endDate,
        period: period,
      );

      if (response['status'] == 'success') {
        return response['data'];
      } else {
        _setError(response['message'] ?? 'Failed to load earnings');
        return null;
      }
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> uploadProfilePicture(String filePath) async {
    try {
      _setLoading(true);

      final uploadResponse = await apiService.uploadFile(
        filePath: filePath,
        fileType: 'profile_picture',
      );

      if (uploadResponse['status'] == 'success') {
        final imageUrl = uploadResponse['data']['file_url'];

        // Update profile with new image URL
        final updateResponse = await apiService.updateDriverProfile({
          'profile_picture': imageUrl,
        });

        if (updateResponse['status'] == 'success') {
          // Refresh profile data
          await getProfile();
          return true;
        }
      }

      _setError('Failed to upload profile picture');
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    try {
      _setLoading(true);

      final response = await apiService.updateDriverProfile(profileData);

      if (response['status'] == 'success') {
        // Refresh profile data
        await getProfile();
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to update profile');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> getDriverApprovalStatus() async {
    try {
      final response = await apiService.getDriverProfile();

      if (response['status'] == 'success') {
        return response['data']['approval_status'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> reportEmergency({
    required double latitude,
    required double longitude,
    required String emergencyType,
    String? description,
  }) async {
    try {
      _setLoading(true);

      final response = await apiService.reportEmergency(
        latitude: latitude,
        longitude: longitude,
        emergencyType: emergencyType,
        description: description,
      );

      if (response['status'] == 'success') {
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to report emergency');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }



  // Login
  Future<bool> login({required String phone, required String password}) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await loginUseCase(
        LoginParams(phone: phone, password: password),
      );

      return result.fold(
        (failure) {
          _setError(failure.message);
          _setState(AuthState.unauthenticated);
          return false;
        },
        (loginResult) {
          _driver = loginResult!.driver;
          _setState(AuthState.authenticated);
          return true;
        },
      );
    } catch (e) {
      _setError('An unexpected error occurred: $e');
      _setState(AuthState.unauthenticated);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<bool> logout() async {
    try {
      _setLoading(true);
      _clearError();

      final result = await logoutUseCase(NoParams());

      return result.fold(
        (failure) {
          _setError(failure.message);
          return false;
        },
        (success) {
          _driver = null;
          _setState(AuthState.unauthenticated);
          return true;
        },
      );
    } catch (e) {
      _setError('Logout failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get Profile
  Future<void> getProfile() async {
    try {
      _setLoading(true);
      _clearError();

      final result = await getProfileUseCase(NoParams());

      result.fold(
        (failure) {
          _setError(failure.message);
          if (failure.message.contains('Unauthorized')) {
            _setState(AuthState.unauthenticated);
          }
        },
        (driver) {
          _driver = driver;
          _setState(AuthState.authenticated);
        },
      );
    } catch (e) {
      _setError('Failed to get profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update Driver Status
  Future<bool> updateDriverStatus(String status) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await updateDriverStatusUseCase(
        UpdateDriverStatusParams(status: status),
      );

      return result.fold(
        (failure) {
          _setError(failure.message);
          return false;
        },
        (success) {
          // Update local driver status
          if (_driver != null) {
            _driver = Driver(
              id: _driver!.id,
              firstName: _driver!.firstName,
              lastName: _driver!.lastName,
              email: _driver!.email,
              phone: _driver!.phone,
              profilePicture: _driver!.profilePicture,
              licenseNumber: _driver!.licenseNumber,
              licenseExpiry: _driver!.licenseExpiry,
              idNumber: _driver!.idNumber,
              rating: _driver!.rating,
              totalRatings: _driver!.totalRatings,
              isAvailable: status == 'online',
              isTrackingEnabled: _driver!.isTrackingEnabled,
              status: status,
              lastLocationUpdate: DateTime.now(),
              currentLatitude: _driver!.currentLatitude,
              currentLongitude: _driver!.currentLongitude,
              createdAt: _driver!.createdAt,
              updatedAt: DateTime.now(),
            );
            notifyListeners();
          }
          return true;
        },
      );
    } catch (e) {
      _setError('Failed to update status: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Check if user is logged in
  Future<void> checkAuthStatus() async {
    try {
      _setLoading(true);

      // Try to get profile, which will validate the token
      await getProfile();
    } catch (e) {
      _setState(AuthState.unauthenticated);
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _state = AuthState.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _state = AuthState.initial;
    }
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  // Reset provider state
  void reset() {
    _state = AuthState.initial;
    _driver = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
