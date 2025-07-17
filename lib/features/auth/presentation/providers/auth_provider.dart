// lib/features/auth/presentation/providers/auth_provider.dart
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

  AuthProvider({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.getProfileUseCase,
    required this.updateDriverStatusUseCase,
  });

  AuthState _state = AuthState.initial;
  Driver? _driver;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  AuthState get state => _state;
  Driver? get driver => _driver;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated =>
      _state == AuthState.authenticated && _driver != null;

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
          _driver = loginResult.driver;
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
