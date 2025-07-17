// // lib/core/services/notification_service.dart
// import 'dart:ui';

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:permission_handler/permission_handler.dart';

// class NotificationService {
//   static final NotificationService _instance = NotificationService._internal();
//   factory NotificationService() => _instance;
//   NotificationService._internal();

//   final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   Future<void> initialize() async {
//     print('🔔 NotificationService: Initializing...');

//     await _requestPermissions();
//     await _initializeNotifications();
//   }

//   Future<void> _requestPermissions() async {
//     try {
//       final status = await Permission.notification.request();
//       if (status != PermissionStatus.granted) {
//         print('❌ Notification permission denied');
//       } else {
//         print('✅ Notification permission granted');
//       }
//     } catch (e) {
//       print('❌ Error requesting notification permission: $e');
//     }
//   }

//   Future<void> _initializeNotifications() async {
//     const androidInitializationSettings = AndroidInitializationSettings(
//       '@mipmap/ic_launcher',
//     );

//     const iosInitializationSettings = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );

//     const initializationSettings = InitializationSettings(
//       android: androidInitializationSettings,
//       iOS: iosInitializationSettings,
//     );

//     await _flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: _onNotificationTapped,
//     );

//     // Create notification channels for Android
//     await _createNotificationChannels();
//   }

//   Future<void> _createNotificationChannels() async {
//     // Trip notifications channel
//     const tripChannel = AndroidNotificationChannel(
//       'trip_notifications',
//       'Trip Notifications',
//       description: 'Notifications related to trips and passengers',
//       importance: Importance.high,
//       sound: RawResourceAndroidNotificationSound('notification_sound'),
//     );

//     // Booking notifications channel
//     const bookingChannel = AndroidNotificationChannel(
//       'booking_notifications',
//       'Booking Notifications',
//       description: 'Notifications for new bookings and passenger updates',
//       importance: Importance.max,
//       sound: RawResourceAndroidNotificationSound('booking_sound'),
//     );

//     // General notifications channel
//     const generalChannel = AndroidNotificationChannel(
//       'general_notifications',
//       'General Notifications',
//       description: 'General app notifications',
//       importance: Importance.defaultImportance,
//     );

//     await _flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin
//         >()
//         ?.createNotificationChannel(tripChannel);

//     await _flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin
//         >()
//         ?.createNotificationChannel(bookingChannel);

//     await _flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin
//         >()
//         ?.createNotificationChannel(generalChannel);
//   }

//   void _onNotificationTapped(NotificationResponse response) {
//     print('🔔 Notification tapped: ${response.payload}');
//     // Handle notification tap based on payload
//     // You can navigate to specific screens here
//   }

//   // Show new booking notification
//   Future<void> showNewBookingNotification({
//     required String passengerName,
//     required String route,
//     required String pickupLocation,
//     int? bookingId,
//   }) async {
//     const notificationDetails = NotificationDetails(
//       android: AndroidNotificationDetails(
//         'booking_notifications',
//         'Booking Notifications',
//         channelDescription: 'Notifications for new bookings',
//         importance: Importance.max,
//         priority: Priority.high,
//         icon: '@mipmap/ic_launcher',
//         color: Color(0xFF00967B),
//         ledColor: Color(0xFF00967B),
//         ledOnMs: 1000,
//         ledOffMs: 500,
//         // vibrationPattern: [0, 1000, 500, 1000],
//       ),
//       iOS: DarwinNotificationDetails(
//         presentAlert: true,
//         presentBadge: true,
//         presentSound: true,
//       ),
//     );

//     await _flutterLocalNotificationsPlugin.show(
//       bookingId ?? DateTime.now().millisecondsSinceEpoch.remainder(100000),
//       'New Booking Request',
//       '$passengerName wants to board at $pickupLocation\nRoute: $route',
//       notificationDetails,
//       payload: 'new_booking:$bookingId',
//     );
//   }

//   // Show trip started notification
//   Future<void> showTripStartedNotification({
//     required String route,
//     required int tripId,
//   }) async {
//     const notificationDetails = NotificationDetails(
//       android: AndroidNotificationDetails(
//         'trip_notifications',
//         'Trip Notifications',
//         channelDescription: 'Trip related notifications',
//         importance: Importance.high,
//         priority: Priority.high,
//         icon: '@mipmap/ic_launcher',
//         color: Color(0xFF00967B),
//         ongoing: true, // Keep notification visible during trip
//       ),
//       iOS: DarwinNotificationDetails(
//         presentAlert: true,
//         presentBadge: true,
//         presentSound: true,
//       ),
//     );

//     await _flutterLocalNotificationsPlugin.show(
//       tripId,
//       'Trip Started',
//       'Your trip on $route has started. Location tracking is active.',
//       notificationDetails,
//       payload: 'trip_started:$tripId',
//     );
//   }

//   // Show passenger boarding notification
//   Future<void> showPassengerBoardingNotification({
//     required String passengerName,
//     required String seatNumber,
//     int? bookingId,
//   }) async {
//     const notificationDetails = NotificationDetails(
//       android: AndroidNotificationDetails(
//         'trip_notifications',
//         'Trip Notifications',
//         channelDescription: 'Trip related notifications',
//         importance: Importance.defaultImportance,
//         priority: Priority.defaultPriority,
//         icon: '@mipmap/ic_launcher',
//         color: Color(0xFF00967B),
//       ),
//       iOS: DarwinNotificationDetails(
//         presentAlert: true,
//         presentBadge: false,
//         presentSound: false,
//       ),
//     );

//     await _flutterLocalNotificationsPlugin.show(
//       bookingId ?? DateTime.now().millisecondsSinceEpoch.remainder(100000),
//       'Passenger Boarded',
//       '$passengerName has boarded (Seat $seatNumber)',
//       notificationDetails,
//       payload: 'passenger_boarded:$bookingId',
//     );
//   }

//   // Show trip completed notification
//   Future<void> showTripCompletedNotification({
//     required String route,
//     required double earnings,
//     required int tripId,
//   }) async {
//     const notificationDetails = NotificationDetails(
//       android: AndroidNotificationDetails(
//         'trip_notifications',
//         'Trip Notifications',
//         channelDescription: 'Trip related notifications',
//         importance: Importance.high,
//         priority: Priority.high,
//         icon: '@mipmap/ic_launcher',
//         color: Color(0xFF388E3C),
//       ),
//       iOS: DarwinNotificationDetails(
//         presentAlert: true,
//         presentBadge: true,
//         presentSound: true,
//       ),
//     );

//     await _flutterLocalNotificationsPlugin.show(
//       tripId + 10000, // Offset to avoid ID conflicts
//       'Trip Completed',
//       'Route: $route\nEarnings: TZS ${earnings.toStringAsFixed(0)}',
//       notificationDetails,
//       payload: 'trip_completed:$tripId',
//     );
//   }

//   // Show general notification
//   Future<void> showGeneralNotification({
//     required String title,
//     required String body,
//     String? payload,
//   }) async {
//     const notificationDetails = NotificationDetails(
//       android: AndroidNotificationDetails(
//         'general_notifications',
//         'General Notifications',
//         channelDescription: 'General app notifications',
//         importance: Importance.defaultImportance,
//         priority: Priority.defaultPriority,
//         icon: '@mipmap/ic_launcher',
//         color: Color(0xFF00967B),
//       ),
//       iOS: DarwinNotificationDetails(
//         presentAlert: true,
//         presentBadge: true,
//         presentSound: true,
//       ),
//     );

//     await _flutterLocalNotificationsPlugin.show(
//       DateTime.now().millisecondsSinceEpoch.remainder(100000),
//       title,
//       body,
//       notificationDetails,
//       payload: payload,
//     );
//   }

//   // Cancel specific notification
//   Future<void> cancelNotification(int id) async {
//     await _flutterLocalNotificationsPlugin.cancel(id);
//   }

//   // Cancel all notifications
//   Future<void> cancelAllNotifications() async {
//     await _flutterLocalNotificationsPlugin.cancelAll();
//   }

//   // Get pending notifications
//   Future<List<PendingNotificationRequest>> getPendingNotifications() async {
//     return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
//   }
// }
