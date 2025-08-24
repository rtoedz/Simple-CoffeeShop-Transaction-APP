import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF8B4513); // Coffee brown
  static const Color secondaryColor = Color(0xFFD2691E); // Chocolate
  static const Color accentColor = Color(0xFFF4A460); // Sandy brown
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF2C2C2C);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textSecondaryColor = Color(0xFF757575);
  
  // Text Styles
  static const TextStyle headingStyle = TextStyle(
    color: textPrimary,
    fontWeight: FontWeight.bold,
    fontSize: 24,
  );
  
  static const TextStyle bodyStyle = TextStyle(
    color: textPrimary,
    fontSize: 16,
  );
  
  static const TextStyle buttonTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
  
  static ThemeData lightTheme = ThemeData(
    primarySwatch: MaterialColor(0xFF8B4513, {
      50: Color(0xFFF5F1ED),
      100: Color(0xFFE6DDD2),
      200: Color(0xFFD5C7B4),
      300: Color(0xFFC4B096),
      400: Color(0xFFB79F80),
      500: Color(0xFF8B4513),
      600: Color(0xFF7D3E11),
      700: Color(0xFF6C360F),
      800: Color(0xFF5C2E0D),
      900: Color(0xFF432209),
    }),
    brightness: Brightness.light,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 2,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: textPrimary),
      bodyMedium: TextStyle(color: textSecondary),
      bodySmall: TextStyle(color: textSecondary),
    ),
  );
  
  static ThemeData darkTheme = ThemeData(
    primarySwatch: MaterialColor(0xFF8B4513, {
      50: Color(0xFF432209),
      100: Color(0xFF5C2E0D),
      200: Color(0xFF6C360F),
      300: Color(0xFF7D3E11),
      400: Color(0xFF8B4513),
      500: Color(0xFFB79F80),
      600: Color(0xFFC4B096),
      700: Color(0xFFD5C7B4),
      800: Color(0xFFE6DDD2),
      900: Color(0xFFF5F1ED),
    }),
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Color(0xFF1E1E1E),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF2D2D2D),
      foregroundColor: Colors.white,
      elevation: 2,
      centerTitle: true,
    ),
  );
}