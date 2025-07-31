import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import '../../../core/utils/size_config.dart';
import '../services/temperature_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/widgets/blur_shapes.dart';

/// Displays live temperature readings in overlaid circles for immediate visual recognition.
/// Uses semantic layouts optimized for one-handed mobile use with large touch targets.
class TemperatureCardsWidget extends StatelessWidget {
  final TemperatureService temperatureService;
  
  const TemperatureCardsWidget({
    super.key,
    required this.temperatureService,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('[TemperatureCardsWidget] build called');
    return FutureBuilder<bool>(
      future: temperatureService.update(),
      builder: (context, snapshot) {
        SizeConfig().init(context);

        debugPrint('[TemperatureCardsWidget] FutureBuilder state: ${snapshot.connectionState}');
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            debugPrint('[TemperatureCardsWidget] Error: ${snapshot.error}');
            return _buildErrorState(context, snapshot);
          }
          try {
            debugPrint('[TemperatureCardsWidget] Rendering temperature cards');
            return _buildTemperatureCards(context, temperatureService);
          } catch (e, stack) {
            debugPrint('[TemperatureCardsWidget] Exception in _buildTemperatureCards: $e\n$stack');
            return Center(
              child: Text(
                'Widget error: $e',
                style: const TextStyle(color: Colors.red, fontSize: 18),
              ),
            );
          }
        }

        if (snapshot.hasError) {
          debugPrint('[TemperatureCardsWidget] Error (loading): ${snapshot.error}');
          return _buildErrorState(context, snapshot);
        }

        debugPrint('[TemperatureCardsWidget] Loading state');
        return _buildLoadingState(context);
      },
    );
  }

  Widget _buildErrorState(BuildContext context, AsyncSnapshot<bool> snapshot) {
    return Center(
      child: Text(
        'Error loading temperature data:\n${snapshot.error}',
        style: const TextStyle(color: Colors.red, fontSize: 18),
        textAlign: TextAlign.center,
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
              text: "${data['airTempFaehrweg']?.last['v']?.toStringAsFixed(1) ?? '?'} °C",
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
            text: "${data['waterTempFaehrweg']?.last['v']?.toStringAsFixed(1) ?? '?'} °C",
            subtitle: AppLocalizations.of(context)!.waterTemperature,
            backgroundColor: const Color.fromRGBO(31, 123, 129, 0.502),
          ),
        ),
        
        // Battery info rectangle (bottom right)
        Positioned(
          bottom: 30,
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
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  String _formatBatteryInfo(Map<String, List<Map<String, dynamic>>> data) {
    final batteryTime = data['batFaehrweg']?.last['t'] ?? DateTime.now();
    final batteryVoltage = data['batFaehrweg']?.last['v']?.toStringAsFixed(2) ?? '?';
    final formattedTime = intl.DateFormat("d.M.yyyy H:mm").format(batteryTime.toLocal());
    return '$formattedTime / $batteryVoltage V';
  }
}
