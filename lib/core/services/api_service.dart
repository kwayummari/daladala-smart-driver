// lib/core/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000/api';

  void initialize() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add request interceptor for authentication
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'driver_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          print('🚀 API Request: ${options.method} ${options.path}');
          print('🚀 Headers: ${options.headers}');
          if (options.data != null) {
            print('🚀 Data: ${options.data}');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          print(
            '✅ API Response: ${response.statusCode} ${response.requestOptions.path}',
          );
          handler.next(response);
        },
        onError: (error, handler) {
          print(
            '❌ API Error: ${error.response?.statusCode} ${error.requestOptions.path}',
          );
          print('❌ Error message: ${error.message}');
          if (error.response?.data != null) {
            print('❌ Error data: ${error.response?.data}');
          }
          handler.next(error);
        },
      ),
    );
  }

  // Driver Authentication
  Future<Map<String, dynamic>> driverLogin(
    String phone,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/driver/login',
        data: {'phone': phone, 'password': password},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> driverRegister(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/auth/driver/register', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Driver Profile
  Future<Map<String, dynamic>> getDriverProfile() async {
    try {
      final response = await _dio.get('/drivers/profile');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateDriverProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put('/drivers/profile', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Driver Status
  Future<Map<String, dynamic>> updateDriverStatus(String status) async {
    try {
      final response = await _dio.put(
        '/drivers/status',
        data: {'status': status, 'is_available': status == 'online'},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Trip Management
  Future<Map<String, dynamic>> getDriverTrips({
    String? status,
    String? date,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (status != null) queryParams['status'] = status;
      if (date != null) queryParams['date'] = date;

      final response = await _dio.get(
        '/drivers/trips',
        queryParameters: queryParams,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getTripDetails(int tripId) async {
    try {
      final response = await _dio.get('/trips/$tripId');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> startTrip(int tripId) async {
    try {
      final response = await _dio.put('/trips/$tripId/start');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> endTrip(int tripId) async {
    try {
      final response = await _dio.put('/trips/$tripId/end');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Location Tracking
  Future<Map<String, dynamic>> updateDriverLocation({
    required int tripId,
    required double latitude,
    required double longitude,
    double? heading,
    double? speed,
  }) async {
    try {
      final response = await _dio.post(
        '/trips/driver/$tripId/location',
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'heading': heading,
          'speed': speed,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // QR Code Validation
  Future<Map<String, dynamic>> validateBookingQR(String qrData) async {
    try {
      final response = await _dio.post(
        '/bookings/validate-qr',
        data: {'qr_data': qrData},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Passenger Management
  Future<Map<String, dynamic>> getTripPassengers(int tripId) async {
    try {
      final response = await _dio.get('/trips/$tripId/passengers');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> markPassengerBoarded(int bookingId) async {
    try {
      final response = await _dio.put('/bookings/$bookingId/board');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> markPassengerDisembarked(int bookingId) async {
    try {
      final response = await _dio.put('/bookings/$bookingId/disembark');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Earnings and Statistics
  Future<Map<String, dynamic>> getDriverEarnings({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final response = await _dio.get(
        '/drivers/earnings',
        queryParameters: queryParams,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getDriverStats() async {
    try {
      final response = await _dio.get('/drivers/stats');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Notifications
  Future<Map<String, dynamic>> getDriverNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/notifications',
        queryParameters: {'page': page, 'limit': limit},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> markNotificationRead(int notificationId) async {
    try {
      final response = await _dio.put('/notifications/$notificationId/read');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Vehicle Management
  Future<Map<String, dynamic>> getDriverVehicle() async {
    try {
      final response = await _dio.get('/drivers/vehicle');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // File Upload
  Future<Map<String, dynamic>> uploadFile(File file, {String? type}) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
        if (type != null) 'type': type,
      });

      final response = await _dio.post('/upload', data: formData);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error handling
  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        if (statusCode == 401) {
          return 'Unauthorized. Please login again.';
        } else if (statusCode == 403) {
          return 'Access forbidden.';
        } else if (statusCode == 404) {
          return 'Resource not found.';
        } else if (statusCode == 422) {
          if (data is Map && data['errors'] != null) {
            return data['errors'].toString();
          }
          return data['message'] ?? 'Validation error.';
        } else if (statusCode == 500) {
          return 'Server error. Please try again later.';
        }

        return data?['message'] ?? 'An error occurred.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return 'No internet connection.';
        }
        return 'An unexpected error occurred.';
      default:
        return 'An error occurred.';
    }
  }

  // Token management
  Future<void> saveDriverToken(String token) async {
    await _storage.write(key: 'driver_token', value: token);
  }

  Future<String?> getDriverToken() async {
    return await _storage.read(key: 'driver_token');
  }

  Future<void> clearDriverToken() async {
    await _storage.delete(key: 'driver_token');
  }
}
