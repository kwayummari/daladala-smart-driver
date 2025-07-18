// lib/core/theme/app_theme.dart
import 'package:daladala_smart_driver/core/utils/hex_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors - Same as passenger app
  static final Color primaryColor = HexColor('#00967B');
  static final Color accentColor = HexColor('#FFB72B');
  static final Color backgroundColor = Colors.white;
  static final Color white = HexColor("#ffffff");
  static final Color surfaceColor = HexColor('#F7F7F7');
  static final Color errorColor = HexColor('#D32F2F');
  static final Color successColor = HexColor('#388E3C');
  static final Color warningColor = HexColor('#FFA000');
  static final Color infoColor = HexColor('#1976D2');

  // Text colors
  static final Color textPrimaryColor = HexColor('#212121');
  static final Color textSecondaryColor = HexColor('#757575');
  static final Color textTertiaryColor = HexColor('#9E9E9E');

  // Driver-specific status colors
  static final Color onlineColor = HexColor('#388E3C');
  static final Color offlineColor = HexColor('#757575');
  static final Color busyColor = HexColor('#FFA000');
  static final Color breakColor = HexColor('#1976D2');

  // Trip status colors
  static final Color pendingColor = HexColor('#FFA000');
  static final Color confirmedColor = HexColor('#1976D2');
  static final Color inProgressColor = HexColor('#00967B');
  static final Color completedColor = HexColor('#388E3C');
  static final Color cancelledColor = HexColor('#D32F2F');

  // Light theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      surface: surfaceColor,
      background: backgroundColor,
      error: errorColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    cardTheme: const CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: BorderSide(color: primaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: HexColor('#E0E0E0')),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: errorColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: errorColor, width: 2),
      ),
      hintStyle: TextStyle(color: textTertiaryColor),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: textTertiaryColor,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: primaryColor,
      unselectedLabelColor: textSecondaryColor,
      indicatorColor: primaryColor,
    ),
    dividerTheme: DividerThemeData(
      color: HexColor('#EEEEEE'),
      thickness: 1,
      space: 1,
    ),
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: TextStyle(
        color: textPrimaryColor,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        color: textPrimaryColor,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        color: textPrimaryColor,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: TextStyle(
        color: textPrimaryColor,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: textPrimaryColor,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        color: textPrimaryColor,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        color: textPrimaryColor,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: textPrimaryColor,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        color: textPrimaryColor,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(color: textPrimaryColor),
      bodyMedium: TextStyle(color: textPrimaryColor),
      bodySmall: TextStyle(color: textSecondaryColor),
      labelLarge: TextStyle(
        color: textPrimaryColor,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: TextStyle(
        color: textPrimaryColor,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(color: textSecondaryColor),
    ),
  );

  // Dark theme for future use
  static ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.dark(),
  );

  // Driver status color helper
  static Color getDriverStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'online' || 'active':
      case 'available':
        return onlineColor;
      case 'offline':
        return offlineColor;
      case 'busy':
      case 'in_progress':
        return busyColor;
      case 'break':
        return breakColor;
      default:
        return textSecondaryColor;
    }
  }

  // Trip status color helper
  static Color getTripStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return pendingColor;
      case 'confirmed':
        return confirmedColor;
      case 'in_progress':
        return inProgressColor;
      case 'completed':
        return completedColor;
      case 'cancelled':
        return cancelledColor;
      default:
        return textSecondaryColor;
    }
  }
}
