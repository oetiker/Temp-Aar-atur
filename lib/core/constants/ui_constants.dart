import 'dart:ui';

/// UI-related constants following Flutter style guide patterns
class UiConstants {
  // Colors - app visual theme
  static const Color barColor = Color.fromRGBO(31, 123, 129, 0.7);
  static const Color primaryBlue = Color.fromRGBO(119, 170, 252, 0.5);
  static const Color primaryTeal = Color.fromRGBO(31, 123, 129, 0.5);
  static const Color overlayDark = Color.fromRGBO(0, 0, 0, 0.4);
  static const Color overlayLight = Color.fromRGBO(0, 0, 0, 0.3);
  
  // Visual effects
  static const double blurSigma = 2.0;
  static const double circleBlurSigma = 1.5;
  
  // Layout spacing
  static const double defaultPadding = 32.0;
  static const double smallPadding = 16.0;
  static const double tinyPadding = 8.0;
  static const double largePadding = 24.0;
  static const double containerPadding = 10.0;
  static const double containerMargin = 5.0;
  
  // Positioning
  static const double defaultOffset = 30.0;
  static const double horizontalBottomOffset = 120.0;
  static const double verticalBottomOffset = 250.0;
  static const double bottomInfoOffset = 10.0;
  
  // Text sizes
  static const double errorTitleSize = 18.0;
  static const double errorBodySize = 14.0;
  static const double largeErrorTitleSize = 24.0;
  static const double infoSubtitleSize = 25.0;
  static const double debugTextSize = 12.0;
  
  // Icon sizes
  static const double errorIconSize = 48.0;
  static const double largeErrorIconSize = 64.0;
  
  // Animation timing
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);
}