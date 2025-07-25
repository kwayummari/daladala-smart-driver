// lib/core/services/api_service.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
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

    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (
      HttpClient client,
    ) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };

    // Auth interceptor
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

  Future<Map<String, dynamic>> getDriverStatistics({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final response = await _dio.get(
        '/drivers/statistics',
        queryParameters: queryParams,
      );
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
    String? period = 'daily', // daily, weekly, monthly
  }) async {
    try {
      final queryParams = <String, dynamic>{'period': period};
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

  Future<Map<String, dynamic>> getAvailableRoutes() async {
    try {
      final response = await _dio.get('/routes');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> assignDriverToRoute(int routeId) async {
    try {
      final response = await _dio.post(
        '/drivers/assign-route',
        data: {'route_id': routeId},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

   Future<Map<String, dynamic>> createTrip({
    required int routeId,
    required String departureTime,
    required double fareAmount,
    int? maxPassengers,
  }) async {
    try {
      final response = await _dio.post(
        '/trips/create',
        data: {
          'route_id': routeId,
          'departure_time': departureTime,
          'fare_amount': fareAmount,
          'max_passengers': maxPassengers,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> cancelTrip(int tripId, String reason) async {
    try {
      final response = await _dio.put(
        '/trips/$tripId/cancel',
        data: {'reason': reason},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateTripStatus({
    required int tripId,
    required String status,
    String? notes,
  }) async {
    try {
      final response = await _dio.put(
        '/trips/$tripId/status',
        data: {'status': status, 'notes': notes},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Passenger Boarding Management
  Future<Map<String, dynamic>> scanPassengerQR(String qrData) async {
    try {
      final response = await _dio.post(
        '/bookings/scan-qr',
        data: {'qr_data': qrData},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> boardPassenger({
    required int bookingId,
    String? notes,
  }) async {
    try {
      final response = await _dio.put(
        '/bookings/$bookingId/board',
        data: {'notes': notes},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> disembarkPassenger({
    required int bookingId,
    String? notes,
  }) async {
    try {
      final response = await _dio.put(
        '/bookings/$bookingId/disembark',
        data: {'notes': notes},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getDriverVehicles() async {
    try {
      final response = await _dio.get('/drivers/vehicles');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateVehicleStatus({
    required int vehicleId,
    required String status,
    String? notes,
  }) async {
    try {
      final response = await _dio.put(
        '/vehicles/$vehicleId/status',
        data: {'status': status, 'notes': notes},
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

  Future<Map<String, dynamic>> getDriverReviews({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/drivers/reviews',
        queryParameters: {'page': page, 'limit': limit},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Notifications
  Future<Map<String, dynamic>> getDriverNotifications({
    int page = 1,
    int limit = 20,
    bool? unreadOnly,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (unreadOnly != null) queryParams['unread_only'] = unreadOnly;

      final response = await _dio.get(
        '/drivers/notifications',
        queryParameters: queryParams,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> markNotificationAsRead(
    int notificationId,
  ) async {
    try {
      final response = await _dio.put('/notifications/$notificationId/read');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> reportEmergency({
    required double latitude,
    required double longitude,
    required String emergencyType,
    String? description,
  }) async {
    try {
      final response = await _dio.post(
        '/drivers/emergency',
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'emergency_type': emergencyType,
          'description': description,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> contactSupport({
    required String subject,
    required String message,
    String? category,
  }) async {
    try {
      final response = await _dio.post(
        '/support/contact',
        data: {'subject': subject, 'message': message, 'category': category},
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
  Future<Map<String, dynamic>> uploadFile({
    required String filePath,
    required String fileType,
  }) async {
    try {
      final fileName = filePath.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
        'file_type': fileType,
      });

      final response = await _dio.post('/files/upload', data: formData);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateDriverDocuments({
    String? licenseImageUrl,
    String? idImageUrl,
    String? vehicleRegistrationUrl,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (licenseImageUrl != null) data['license_image_url'] = licenseImageUrl;
      if (idImageUrl != null) data['id_image_url'] = idImageUrl;
      if (vehicleRegistrationUrl != null) {
        data['vehicle_registration_url'] = vehicleRegistrationUrl;
      }

      final response = await _dio.put('/drivers/documents', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getTripHistory({
    String? startDate,
    String? endDate,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;
      if (status != null) queryParams['status'] = status;

      final response = await _dio.get(
        '/drivers/trip-history',
        queryParameters: queryParams,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getTripAnalytics({
    String period = 'monthly', // daily, weekly, monthly, yearly
    int? year,
    int? month,
  }) async {
    try {
      final queryParams = <String, dynamic>{'period': period};
      if (year != null) queryParams['year'] = year;
      if (month != null) queryParams['month'] = month;

      final response = await _dio.get(
        '/drivers/analytics',
        queryParameters: queryParams,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getRouteDetails(int routeId) async {
    try {
      final response = await _dio.get('/routes/$routeId');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getRouteStops(int routeId) async {
    try {
      final response = await _dio.get('/routes/$routeId/stops');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getPerformanceMetrics({
    String period = 'monthly',
  }) async {
    try {
      final response = await _dio.get(
        '/drivers/performance',
        queryParameters: {'period': period},
      );
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
