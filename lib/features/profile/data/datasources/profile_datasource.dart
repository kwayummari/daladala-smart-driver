// lib/features/profile/data/datasources/profile_datasource.dart
import 'package:daladala_smart_driver/core/usecases/usecase.dart';
import 'package:daladala_smart_driver/features/profile/data/models/profile_model.dart';

import '../../../../core/services/api_service.dart';

abstract class ProfileDataSource {
  Future<ProfileModel> getProfile();
  Future<ProfileModel> updateProfile(Map<String, dynamic> profileData);
}

class ProfileDataSourceImpl implements ProfileDataSource {
  final ApiService apiService;

  ProfileDataSourceImpl(this.apiService);

  @override
  Future<ProfileModel> getProfile() async {
    try {
      final response = await apiService.getDriverProfile();

      if (response['status'] == 'success') {
        return ProfileModel.fromJson(response['data']);
      } else {
        throw ServerException(response['message'] ?? 'Failed to get profile');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ProfileModel> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await apiService.updateDriverProfile(profileData);

      if (response['status'] == 'success') {
        return ProfileModel.fromJson(response['data']);
      } else {
        throw ServerException(
          response['message'] ?? 'Failed to update profile',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }
}
