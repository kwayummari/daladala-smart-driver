// lib/features/trip/data/datasources/trip_datasource.dart
import 'package:daladala_smart_driver/core/usecases/usecase.dart';

import '../../../../core/services/api_service.dart';
import '../models/trip_model.dart';

abstract class TripDataSource {
  Future<List<TripModel>> getDriverTrips({
    String? status,
    String? date,
    int page = 1,
    int limit = 20,
  });

  Future<TripModel> getTripDetails(int tripId);
  Future<bool> startTrip(int tripId);
  Future<bool> endTrip(int tripId);

  Future<bool> updateLocation({
    required int tripId,
    required double latitude,
    required double longitude,
    double? speed,
    double? heading,
  });

  Future<List<TripPassengerModel>> getTripPassengers(int tripId);
  Future<bool> markPassengerBoarded(int bookingId);
  Future<bool> markPassengerDisembarked(int bookingId);
}

class TripDataSourceImpl implements TripDataSource {
  final ApiService apiService;

  TripDataSourceImpl(this.apiService);

  @override
  Future<List<TripModel>> getDriverTrips({
    String? status,
    String? date,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await apiService.getDriverTrips(
        status: status,
        date: date,
        page: page,
        limit: limit,
      );

      if (response['status'] == 'success') {
        final tripsData = response['data'] as List;
        return tripsData.map((trip) => TripModel.fromJson(trip)).toList();
      } else {
        throw ServerException(response['message'] ?? 'Failed to get trips');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<TripModel> getTripDetails(int tripId) async {
    try {
      final response = await apiService.getTripDetails(tripId);

      if (response['status'] == 'success') {
        return TripModel.fromJson(response['data']);
      } else {
        throw ServerException(
          response['message'] ?? 'Failed to get trip details',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> startTrip(int tripId) async {
    try {
      final response = await apiService.startTrip(tripId);

      if (response['status'] == 'success') {
        return true;
      } else {
        throw ServerException(response['message'] ?? 'Failed to start trip');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> endTrip(int tripId) async {
    try {
      final response = await apiService.endTrip(tripId);

      if (response['status'] == 'success') {
        return true;
      } else {
        throw ServerException(response['message'] ?? 'Failed to end trip');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> updateLocation({
    required int tripId,
    required double latitude,
    required double longitude,
    double? speed,
    double? heading,
  }) async {
    try {
      final response = await apiService.updateDriverLocation(
        tripId: tripId,
        latitude: latitude,
        longitude: longitude,
        speed: speed,
        heading: heading,
      );

      if (response['status'] == 'success') {
        return true;
      } else {
        throw ServerException(
          response['message'] ?? 'Failed to update location',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<TripPassengerModel>> getTripPassengers(int tripId) async {
    try {
      final response = await apiService.getTripPassengers(tripId);

      if (response['status'] == 'success') {
        final passengersData = response['data'] as List;
        return passengersData
            .map((passenger) => TripPassengerModel.fromJson(passenger))
            .toList();
      } else {
        throw ServerException(
          response['message'] ?? 'Failed to get passengers',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> markPassengerBoarded(int bookingId) async {
    try {
      final response = await apiService.markPassengerBoarded(bookingId);

      if (response['status'] == 'success') {
        return true;
      } else {
        throw ServerException(
          response['message'] ?? 'Failed to mark passenger as boarded',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> markPassengerDisembarked(int bookingId) async {
    try {
      final response = await apiService.markPassengerDisembarked(bookingId);

      if (response['status'] == 'success') {
        return true;
      } else {
        throw ServerException(
          response['message'] ?? 'Failed to mark passenger as disembarked',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }
}
