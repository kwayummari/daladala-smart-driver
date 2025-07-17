// lib/features/profile/presentation/providers/profile_provider.dart
import 'package:flutter/material.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/driver.dart';
import '../../../auth/domain/usecases/get_profile_usecase.dart';
import '../../../auth/domain/usecases/update_driver_status_usecase.dart';

enum ProfileState { initial, loading, loaded, error }

class ProfileProvider extends ChangeNotifier {
  final GetProfileUseCase getProfileUseCase;
  final UpdateDriverStatusUseCase updateDriverStatusUseCase;

  ProfileProvider({
    required this.getProfileUseCase,
    required this.updateDriverStatusUseCase,
  });

  ProfileState _state = ProfileState.initial;
  Driver? _driver;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  ProfileState get state => _state;
  Driver? get driver => _driver;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  // Load profile
  Future<void> loadProfile() async {
    try {
      _setLoading(true);
      _clearError();

      final result = await getProfileUseCase(NoParams());

      result.fold((failure) => _setError(failure.message), (driver) {
        _driver = driver;
        _setState(ProfileState.loaded);
      });
    } catch (e) {
      _setError('Failed to load profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update driver status
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

  // Update profile information
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? profilePicture,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      if (_driver == null) {
        _setError('No driver data available');
        return false;
      }

      // Create updated driver object
      final updatedDriver = Driver(
        id: _driver!.id,
        firstName: firstName ?? _driver!.firstName,
        lastName: lastName ?? _driver!.lastName,
        email: email ?? _driver!.email,
        phone: phone ?? _driver!.phone,
        profilePicture: profilePicture ?? _driver!.profilePicture,
        licenseNumber: _driver!.licenseNumber,
        licenseExpiry: _driver!.licenseExpiry,
        idNumber: _driver!.idNumber,
        rating: _driver!.rating,
        totalRatings: _driver!.totalRatings,
        isAvailable: _driver!.isAvailable,
        isTrackingEnabled: _driver!.isTrackingEnabled,
        status: _driver!.status,
        lastLocationUpdate: _driver!.lastLocationUpdate,
        currentLatitude: _driver!.currentLatitude,
        currentLongitude: _driver!.currentLongitude,
        createdAt: _driver!.createdAt,
        updatedAt: DateTime.now(),
      );

      // TODO: Call API to update profile
      // For now, just update local state
      _driver = updatedDriver;
      _setState(ProfileState.loaded);
      return true;
    } catch (e) {
      _setError('Failed to update profile: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Set driver from auth provider
  void setDriver(Driver driver) {
    _driver = driver;
    _setState(ProfileState.loaded);
  }

  // Clear driver data
  void clearDriver() {
    _driver = null;
    _setState(ProfileState.initial);
  }

  // Helper methods
  void _setState(ProfileState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _state = ProfileState.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    if (_state == ProfileState.error) {
      _state = ProfileState.initial;
    }
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
