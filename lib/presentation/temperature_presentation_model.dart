import 'dart:math';
import 'package:flutter/material.dart';
import '../services/temperature_service.dart';
import '../size_config.dart';
import '../l10n/app_localizations.dart';
import 'package:intl/intl.dart' as intl;

class TemperaturePresentationModel {
  final TemperatureService _temperatureService;
  
  TemperaturePresentationModel(this._temperatureService);

  bool get isOffline => _temperatureService.isOffline;
  
  String get currentWaterTemperatureText {
    final temp = _temperatureService.currentWaterTemperature;
    return temp != null ? "${temp.toStringAsFixed(1)} °C" : "? °C";
  }
  
  String get currentAirTemperatureText {
    final temp = _temperatureService.currentAirTemperature;
    return temp != null ? "${temp.toStringAsFixed(1)} °C" : "? °C";
  }
  
  String get batteryInfoText {
    final voltage = _temperatureService.currentBatteryVoltage;
    final time = _temperatureService.lastMeasurementTime;
    final timeText = intl.DateFormat("d.M.yyyy H:mm").format((time ?? DateTime.now()).toLocal());
    final voltageText = voltage?.toStringAsFixed(2) ?? '?';
    return '$timeText / $voltageText V';
  }
  
  String accessibilityAnnouncementText(BuildContext context) {
    final waterTemp = _temperatureService.currentWaterTemperature?.toStringAsFixed(1) ?? '?';
    final airTemp = _temperatureService.currentAirTemperature?.toStringAsFixed(1) ?? '?';
    return AppLocalizations.of(context)!.temperatureUpdate(waterTemp, airTemp);
  }
  
  String errorTitle(BuildContext context) {
    return isOffline 
        ? AppLocalizations.of(context)!.noConnection 
        : AppLocalizations.of(context)!.dataLoadError;
  }
  
  String errorMessage(BuildContext context) {
    return isOffline 
        ? AppLocalizations.of(context)!.checkNetwork
        : AppLocalizations.of(context)!.tryAgainLater;
  }
  
  double getAirTempCircleSize(double baseSize, double factor) {
    return baseSize / factor;
  }
  
  double getWaterTempCircleSize(double baseSize, double factor) {
    return baseSize * factor;
  }
  
  double getBatteryInfoWidth(double baseSize, double factor) {
    return baseSize * factor;
  }
  
  bool isHorizontalLayout() {
    return SizeConfig.screenHeight < SizeConfig.screenWidth;
  }
  
  double getBaseSize() {
    return min(SizeConfig.screenWidth, SizeConfig.screenHeight);
  }
  
  Future<bool> updateTemperatureData() {
    return _temperatureService.updateTemperatureData();
  }
}