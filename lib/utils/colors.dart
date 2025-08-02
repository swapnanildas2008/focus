import 'package:flutter/material.dart';

class AppColors {
  // Primary Forest Colors
  static const MaterialColor forestGreen = MaterialColor(
    0xFF2E7D32,
    <int, Color>{
      50: Color(0xFFE8F5E8),
      100: Color(0xFFC8E6C9),
      200: Color(0xFFA5D6A7),
      300: Color(0xFF81C784),
      400: Color(0xFF66BB6A),
      500: Color(0xFF4CAF50),
      600: Color(0xFF43A047),
      700: Color(0xFF388E3C),
      800: Color(0xFF2E7D32),
      900: Color(0xFF1B5E20),
    },
  );

  // Accent Colors
  static const Color accentOrange = Color(0xFFFF7043);
  static const Color accentPink = Color(0xFFEC407A);
  static const Color accentPurple = Color(0xFF7E57C2);
  static const Color accentBlue = Color(0xFF42A5F5);
  static const Color accentTeal = Color(0xFF26A69A);

  // Background Colors
  static const Color lightBackground = Color(0xFFF1F8E9);
  static const Color darkBackground = Color(0xFF1B5E20);
  
  // Task Priority Colors
  static const Color highPriority = Color(0xFFD32F2F);
  static const Color mediumPriority = Color(0xFFF57C00);
  static const Color lowPriority = Color(0xFF388E3C);
  
  // Status Colors
  static const Color completedTask = Color(0xFF4CAF50);
  static const Color pendingTask = Color(0xFFFF9800);
  static const Color overdueTask = Color(0xFFE53935);

  static var white;
}
