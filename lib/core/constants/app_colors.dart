import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1D4ED8);

  // Status colors
  static const Color todo = Color(0xFF64748B);
  static const Color inProgress = Color(0xFFF59E0B);
  static const Color done = Color(0xFF10B981);

  // Priority colors
  static const Color priorityLow = Color(0xFF6EE7B7);
  static const Color priorityMedium = Color(0xFFFBBF24);
  static const Color priorityHigh = Color(0xFFF87171);

  // Project palette (10 colors to pick from)
  static const List<Color> projectColors = [
    Color(0xFF2563EB), // Blue
    Color(0xFF7C3AED), // Violet
    Color(0xFFDB2777), // Pink
    Color(0xFFDC2626), // Red
    Color(0xFFEA580C), // Orange
    Color(0xFFCA8A04), // Yellow
    Color(0xFF16A34A), // Green
    Color(0xFF0891B2), // Cyan
    Color(0xFF475569), // Slate
    Color(0xFF92400E), // Brown
  ];

  static const Color surface = Color(0xFFF8FAFC);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF334155);
}
