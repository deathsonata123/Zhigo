import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography System - Inter Font Family
/// All text in the app must use Inter font
class AppTextStyles {
  AppTextStyles._();

  // H1 (Heading) - Screen titles (e.g., "Checkout")
  static TextStyle h1 = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w600, // SemiBold
    height: 1.2,
  );

  // H2 (Subheading) - Section titles (e.g., "Your Cart")
  static TextStyle h2 = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600, // SemiBold
    height: 1.3,
  );

  // Body (Primary) - All main paragraphs, descriptions
  static TextStyle bodyPrimary = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400, // Regular
    height: 1.5,
  );

  // Body (Emphasized) - Item titles, important labels
  static TextStyle bodyEmphasized = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500, // Medium
    height: 1.5,
  );

  // Button Text
  static TextStyle button = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500, // Medium
    height: 1.2,
  );

  // Small Text - Captions, timestamps, helper text
  static TextStyle small = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400, // Regular
    height: 1.4,
  );
  
  // Helper - Apply Inter font family to any TextStyle
  static TextStyle inter(TextStyle style) {
    return GoogleFonts.inter(textStyle: style);
  }
}
