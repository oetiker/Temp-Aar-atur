import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import '../size_config.dart';
import '../services/service_locator.dart';
import '../services/temperature_service.dart';
import '../l10n/app_localizations.dart';
import '../widgets/blur_shapes.dart';

/// Widget that displays the current temperature cards with air, water, and battery info
class TemperatureCardsWidget extends StatelessWidget {
  const TemperatureCardsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final temperatureService = ServiceLocator().get<TemperatureService>();
    
    return FutureBuilder<bool>(
      future: temperatureService.updateLatestData(),
      builder: (context, snapshot) {
        SizeConfig().init(context);
        
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return _buildErrorState(context, snapshot);
          }
          
          return _buildTemperatureCards(context, temperatureService);
        }
        
        return _buildLoadingState(context);
      },
    );
  }

  Widget _buildErrorState(BuildContext context, AsyncSnapshot<bool> snapshot) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.dataLoadError,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Text(
            '${AppLocalizations.of(context)!.errorDetails} ${snapshot.error}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTemperatureCards(BuildContext context, TemperatureService temperatureService) {
    final data = temperatureService.data;
    final baseSize = min(SizeConfig.screenWidth, SizeConfig.screenHeight);
    final isHorizontal = SizeConfig.screenHeight < SizeConfig.screenWidth;

    return Stack(
      children: [
        // Air temperature circle (top right)
        Positioned(
          top: 30,
          right: 30,
          child: Semantics(
            label: AppLocalizations.of(context)!.temperatureUpdate(
              data['waterTempFaehrweg']?.last['v']?.toStringAsFixed(1) ?? '?',
              data['airTempFaehrweg']?.last['v']?.toStringAsFixed(1) ?? '?',
            ),
            child: BlurShapes.circle(
              width: baseSize / 2.3,
              text: "${data['airTempFaehrweg']?.last['v']?.toStringAsFixed(1) ?? '?'} °C",
              subtitle: AppLocalizations.of(context)!.airTemperature,
              backgroundColor: const Color.fromRGBO(119, 170, 252, 0.5),
            ),
          ),
        ),
        
        // Water temperature circle (bottom left)
        Positioned(
          bottom: 30,
          left: 30,
          child: BlurShapes.circle(
            width: baseSize * (isHorizontal ? 0.6 : 0.8),
            text: "${data['waterTempFaehrweg']?.last['v']?.toStringAsFixed(1) ?? '?'} °C",
            subtitle: AppLocalizations.of(context)!.waterTemperature,
            backgroundColor: const Color.fromRGBO(31, 123, 129, 0.502),
          ),
        ),
        
        // Battery info rectangle (bottom right)
        Positioned(
          bottom: 80,
          right: 30,
          child: Semantics(
            label: AppLocalizations.of(context)!.lastMeasurementAndBattery(
              _formatBatteryInfo(data),
            ),
            child: BlurShapes.rectangle(
              text: _formatBatteryInfo(data),
              width: baseSize * 0.3,
              backgroundColor: const Color.fromRGBO(0, 0, 0, 0.3),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context)!.loading,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  String _formatBatteryInfo(Map<String, List<Map<String, dynamic>>> data) {
    final batteryTime = data['batFaehrweg']?.last['t'] ?? DateTime.now();
    final batteryVoltage = data['batFaehrweg']?.last['v']?.toStringAsFixed(2) ?? '?';
    final formattedTime = intl.DateFormat("d.M.yyyy H:mm").format(batteryTime.toLocal());
    return '$formattedTime / $batteryVoltage V';
  }
}