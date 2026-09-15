import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryDark = Color(0xFF0F1E3D);
  static const Color background = Color(0xFFF4F6F8);
  static const Color cardColor = Colors.white;
  
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentYellow = Color(0xFFF59E0B);
  static const Color accentPurple = Color(0xFF8B5CF6);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryDark,
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryDark,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: accentGreen,
        unselectedItemColor: textSecondary,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
