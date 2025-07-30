import 'dart:ui';

class AppConstants {
  // Timer intervals  
  static const Duration dataRefreshInterval = Duration(seconds: 700); // 10 minutes + 100 seconds buffer
  
  // Progressive data loading intervals
  static const Duration initialDataPeriod = Duration(hours: 1); // For current temperature display
  static const Duration chartDataPeriod = Duration(days: 7); // For initial chart view
  static const Duration extendedDataPeriod = Duration(days: 30); // For extended chart navigation
  static const Duration fullDataPeriod = Duration(days: 365); // For full historical data
  
  // Animation durations
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);
  
  // Colors
  static const Color barColor = Color.fromRGBO(31, 123, 129, 0.7);
  static const Color primaryBlue = Color.fromRGBO(119, 170, 252, 0.5);
  static const Color primaryTeal = Color.fromRGBO(31, 123, 129, 0.5);
  static const Color overlayDark = Color.fromRGBO(0, 0, 0, 0.4);
  static const Color overlayLight = Color.fromRGBO(0, 0, 0, 0.3);
  
  // UI sizes
  static const double blurSigma = 2.0;
  static const double circleBlurSigma = 1.5;
  static const double containerPadding = 10.0;
  static const double containerMargin = 5.0;
  
  // Temperature circle sizing factors
  static const double airTempCircleFactor = 2.3;
  static const double waterTempCircleFactor = 0.6;
  static const double batteryInfoWidthFactor = 0.3;
  
  // Positioning offsets
  static const double defaultOffset = 30.0;
  static const double horizontalBottomOffset = 120.0;
  static const double verticalBottomOffset = 250.0;
  static const double bottomInfoOffset = 10.0;
  
  // Error widget sizes
  static const double errorIconSize = 48.0;
  static const double largeErrorIconSize = 64.0;
  
  // Text sizes
  static const double errorTitleSize = 18.0;
  static const double errorBodySize = 14.0;
  static const double largeErrorTitleSize = 24.0;
  static const double infoSubtitleSize = 25.0;
  static const double debugTextSize = 12.0;
  
  // Chart text sizes
  static const double chartTitleSize = 20.0;
  static const double chartTimestampSize = 12.0;
  static const double chartLabelSize = 12.0;
  
  // Chart layout
  static const double chartLeftPadding = 70.0;
  static const double chartRightPadding = 20.0;
  static const double chartTitleSpacing = 15.0;
  
  // Padding and margins
  static const double defaultPadding = 32.0;
  static const double smallPadding = 16.0;
  static const double tinyPadding = 8.0;
  static const double largePadding = 24.0;
}