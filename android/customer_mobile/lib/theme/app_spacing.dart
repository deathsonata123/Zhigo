/// Spacing System - 8px Grid
/// All padding, margins, and component dimensions must be multiples of 8
class AppSpacing {
  AppSpacing._();

  // Base unit: 8px
  static const double unit = 8.0;

  // Spacing scale (multiples of 8)
  static const double xs = unit; // 8px
  static const double sm = unit * 2; // 16px
  static const double md = unit * 3; // 24px
  static const double lg = unit * 4; // 32px
  static const double xl = unit * 5; // 40px
  static const double xxl = unit * 6; // 48px
  static const double xxxl = unit * 8; // 64px

  // Horizontal screen margin (creates "luxury" whitespace)
  static const double screenMarginHorizontal = md; // 24px
  
  // Vertical screen padding
  static const double screenPaddingVertical = md; // 24px
  
  // Card padding
  static const double cardPadding = sm; // 16px
  
  // Section spacing
  static const double sectionSpacing = lg; // 32px
}
