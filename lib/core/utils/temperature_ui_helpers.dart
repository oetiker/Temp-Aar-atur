import 'dart:math';
import 'package:flutter/material.dart';
import 'size_config.dart';
import '../../features/temperature/models/temperature_reading.dart';
import '../../features/temperature/models/battery_info.dart';
import '../../l10n/app_localizations.dart';
import 'package:intl/intl.dart' as intl;

/// UI helper utilities for temperature display
/// Follows Flutter style guide pattern - pure functions without state
class TemperatureUiHelpers {
  TemperatureUiHelpers._(); // Private constructor - utility class

  /// Format temperature reading for display, handling null values
  static String formatTemperature(TemperatureReading? reading) {
    return reading?.displayText ?? '? °C';
  }

  /// Format battery info with timestamp for display
  static String formatBatteryInfo(BatteryInfo? battery) {
    if (battery == null) {
      return '${intl.DateFormat("d.M.yyyy H:mm").format(DateTime.now().toLocal())} / ? V';
    }
    
    final timeText = intl.DateFormat("d.M.yyyy H:mm").format(battery.timestamp.toLocal());
    return '$timeText / ${battery.displayText}';
  }

  /// Create accessibility announcement text for temperature updates
  static String createAccessibilityText(
    BuildContext context,
    TemperatureReading? waterTemp,
    TemperatureReading? airTemp,
  ) {
    final waterTempValue = waterTemp?.value.toStringAsFixed(1) ?? '?';
    final airTempValue = airTemp?.value.toStringAsFixed(1) ?? '?';
    return AppLocalizations.of(context)!.temperatureUpdate(waterTempValue, airTempValue);
  }

  /// Get appropriate error title based on connection status
  static String getErrorTitle(BuildContext context, bool isOffline) {
    return isOffline 
        ? AppLocalizations.of(context)!.noConnection 
        : AppLocalizations.of(context)!.dataLoadError;
  }

  /// Get appropriate error message based on connection status
  static String getErrorMessage(BuildContext context, bool isOffline) {
    return isOffline 
        ? AppLocalizations.of(context)!.checkNetwork
        : AppLocalizations.of(context)!.tryAgainLater;
  }

  /// Calculate circle size for air temperature display
  static double getAirTempCircleSize(double baseSize, double factor) {
    return baseSize / factor;
  }

  /// Calculate circle size for water temperature display
  static double getWaterTempCircleSize(double baseSize, double factor) {
    return baseSize * factor;
  }

  /// Calculate width for battery info display
  static double getBatteryInfoWidth(double baseSize, double factor) {
    return baseSize * factor;
  }

  /// Check if current layout should be horizontal
  static bool isHorizontalLayout() {
    return SizeConfig.screenHeight < SizeConfig.screenWidth;
  }

  /// Get base size for responsive calculations
  static double getBaseSize() {
    return min(SizeConfig.screenWidth, SizeConfig.screenHeight);
  }
}