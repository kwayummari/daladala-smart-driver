// lib/main.dart
import 'package:daladala_smart_driver/features/profile/presentation/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'core/services/location_service.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/trip/presentation/providers/trip_provider.dart';
import 'features/qr_scanner/presentation/providers/qr_provider.dart';
import 'features/splash/presentation/pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize services
  await setupServiceLocator();

  // Initialize location service
  await getIt<LocationService>().initialize();

  // Initialize notification service
  // await getIt<NotificationService>().initialize();
  await requestPermissions();

  runApp(const DriverApp());
}

Future<void> requestPermissions() async {
  await [
    Permission.sms,
    Permission.storage,
    Permission.notification,
    Permission.locationAlways,
    Permission.locationWhenInUse,
    Permission.location,
  ].request();
}

class DriverApp extends StatelessWidget {
  const DriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => getIt<AuthProvider>(),
        ),
        ChangeNotifierProvider<TripProvider>(
          create: (_) => getIt<TripProvider>(),
        ),
        ChangeNotifierProvider<ProfileProvider>(
          create: (_) => getIt<ProfileProvider>(),
        ),
        ChangeNotifierProvider<QRProvider>(create: (_) => getIt<QRProvider>()),
        Provider<LocationService>(create: (_) => getIt<LocationService>()),
      ],
      child: MaterialApp(
        title: 'Daladala Smart Driver',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
            child: child!,
          );
        },
      ),
    );
  }
}
