import 'package:flutter/material.dart';

/// Sophisticated Warmth Color Palette
/// 90% monochrome with Earthy Terracotta accent
class AppColors {
  AppColors._();

  // Accent (Action) - Used ONLY for primary actions
  static const Color accent = Color(0xFFE07A5F); // Earthy Terracotta
  static const Color secondary = Color(0xFFF4A261); // Lighter terracotta for gradients
  
  // Base Colors
  static const Color baseBlack = Color(0xFF0C0C0C); // Primary text, dark mode bg (future)
  static const Color baseOffWhite = Color(0xFFF5F5F5); // Main app background/canvas
  static const Color baseWhite = Color(0xFFFFFFFF); // Card backgrounds, modals, sheets
  
  // Text
  static const Color textPrimary = baseBlack;
  static const Color textSecondary = Color(0xFF8A8A8A); // Secondary info, placeholders, disabled states
  
  // Semantic colors (derived from base palette)
  static const Color background = baseOffWhite;
  static const Color surface = baseWhite;
  static const Color border = Color(0xFFE0E0E0);
  
  // Status colors (minimal use)
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA726);
}
