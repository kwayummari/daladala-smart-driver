// lib/features/auth/data/datasources/auth_datasource.dart
import 'package:daladala_smart_driver/core/usecases/usecase.dart';

import '../../../../core/services/api_service.dart';
import '../models/driver_model.dart';

abstract class AuthDataSource {
  Future<LoginResultModel> login(String phone, String password);
  Future<bool> logout();
  Future<DriverModel> getProfile();
  Future<bool> updateDriverStatus(String status);
  Future<bool> isLoggedIn();
}

class AuthDataSourceImpl implements AuthDataSource {
  final ApiService apiService;

  AuthDataSourceImpl(this.apiService);

  @override
  Future<LoginResultModel> login(String phone, String password) async {
    try {
      final response = await apiService.driverLogin(phone, password);

      print('Login response: $response');

      if (response['status'] == 'success') {
        // Save token
        await apiService.saveDriverToken(response['data']['token']);

        return LoginResultModel.fromJson(response['data']);
      } else {
        throw ServerException(response['message'] ?? 'Login failed');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> logout() async {
    try {
      // Clear token
      await apiService.clearDriverToken();
      return true;
    } catch (e) {
      throw ServerException('Logout failed: $e');
    }
  }

  @override
  Future<DriverModel> getProfile() async {
    try {
      final response = await apiService.getDriverProfile();

      if (response['status'] == 'success') {
        return DriverModel.fromJson(response['data']);
      } else {
        throw ServerException(response['message'] ?? 'Failed to get profile');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> updateDriverStatus(String status) async {
    try {
      final response = await apiService.updateDriverStatus(status);

      if (response['status'] == 'success') {
        return true;
      } else {
        throw ServerException(response['message'] ?? 'Failed to update status');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final token = await apiService.getDriverToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
