// lib/core/di/service_locator.dart
import 'package:daladala_smart_driver/features/auth/domain/repositories/auth_repository_impl.dart';
import 'package:get_it/get_it.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../services/socket_service.dart';
import '../services/qr_service.dart';

// Auth imports
import '../../features/auth/data/datasources/auth_datasource.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/get_profile_usecase.dart';
import '../../features/auth/domain/usecases/update_driver_status_usecase.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

// Trip imports
import '../../features/trip/data/datasources/trip_datasource.dart';
import '../../features/trip/data/repositories/trip_repository_impl.dart';
import '../../features/trip/domain/repositories/trip_repository.dart';
import '../../features/trip/domain/usecases/get_driver_trips_usecase.dart';
import '../../features/trip/domain/usecases/start_trip_usecase.dart';
import '../../features/trip/domain/usecases/end_trip_usecase.dart';
import '../../features/trip/domain/usecases/update_location_usecase.dart';
import '../../features/trip/domain/usecases/get_trip_passengers_usecase.dart';
import '../../features/trip/domain/usecases/manage_passenger_usecase.dart';
import '../../features/trip/presentation/providers/trip_provider.dart';

// Profile imports
import '../../features/profile/presentation/providers/profile_provider.dart';

// QR Scanner imports
import '../../features/qr_scanner/data/datasources/qr_datasource.dart';
import '../../features/qr_scanner/data/repositories/qr_repository_impl.dart';
import '../../features/qr_scanner/domain/repositories/qr_repository.dart';
import '../../features/qr_scanner/domain/usecases/validate_qr_usecase.dart';
import '../../features/qr_scanner/presentation/providers/qr_provider.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Core Services
  getIt.registerLazySingleton<ApiService>(() {
    final apiService = ApiService();
    apiService.initialize();
    return apiService;
  });

  getIt.registerLazySingleton<LocationService>(() => LocationService());
  // getIt.registerLazySingleton<NotificationService>(() => NotificationService());
  getIt.registerLazySingleton<SocketService>(() => SocketService());
  getIt.registerLazySingleton<QRService>(() => QRService());

  // Data Sources
  getIt.registerLazySingleton<AuthDataSource>(
    () => AuthDataSourceImpl(getIt<ApiService>()),
  );

  getIt.registerLazySingleton<TripDataSource>(
    () => TripDataSourceImpl(getIt<ApiService>()),
  );

  getIt.registerLazySingleton<QRDataSource>(
    () => QRDataSourceImpl(getIt<ApiService>()),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthDataSource>()),
  );

  getIt.registerLazySingleton<TripRepository>(
    () => TripRepositoryImpl(getIt<TripDataSource>()),
  );

  getIt.registerLazySingleton<QRRepository>(
    () => QRRepositoryImpl(getIt<QRDataSource>()),
  );

  // Auth Use Cases
  getIt.registerLazySingleton(() => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => GetProfileUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(
    () => UpdateDriverStatusUseCase(getIt<AuthRepository>()),
  );

  // Trip Use Cases
  getIt.registerLazySingleton(
    () => GetDriverTripsUseCase(getIt<TripRepository>()),
  );
  getIt.registerLazySingleton(() => StartTripUseCase(getIt<TripRepository>()));
  getIt.registerLazySingleton(() => EndTripUseCase(getIt<TripRepository>()));
  getIt.registerLazySingleton(
    () => UpdateLocationUseCase(getIt<TripRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetTripPassengersUseCase(getIt<TripRepository>()),
  );
  getIt.registerLazySingleton(
    () => MarkPassengerBoardedUseCase(getIt<TripRepository>()),
  );
  getIt.registerLazySingleton(
    () => MarkPassengerDisembarkedUseCase(getIt<TripRepository>()),
  );

  // QR Use Cases
  getIt.registerLazySingleton(() => ValidateQRUseCase(getIt<QRRepository>()));

  // Providers
  getIt.registerFactory(
    () => AuthProvider(
      loginUseCase: getIt<LoginUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
      getProfileUseCase: getIt<GetProfileUseCase>(),
      updateDriverStatusUseCase: getIt<UpdateDriverStatusUseCase>(),
    ),
  );

  getIt.registerFactory(
    () => TripProvider(
      getDriverTripsUseCase: getIt<GetDriverTripsUseCase>(),
      startTripUseCase: getIt<StartTripUseCase>(),
      endTripUseCase: getIt<EndTripUseCase>(),
      updateLocationUseCase: getIt<UpdateLocationUseCase>(),
      getTripPassengersUseCase: getIt<GetTripPassengersUseCase>(),
      markPassengerBoardedUseCase: getIt<MarkPassengerBoardedUseCase>(),
      markPassengerDisembarkedUseCase: getIt<MarkPassengerDisembarkedUseCase>(),
      locationService: getIt<LocationService>(),
      socketService: getIt<SocketService>(),
      // notificationService: getIt<NotificationService>(),
    ),
  );

  getIt.registerFactory(
    () => ProfileProvider(
      getProfileUseCase: getIt<GetProfileUseCase>(),
      updateDriverStatusUseCase: getIt<UpdateDriverStatusUseCase>(),
    ),
  );

  getIt.registerFactory(
    () => QRProvider(
      validateQRUseCase: getIt<ValidateQRUseCase>(),
      qrService: getIt<QRService>(),
    ),
  );
}
