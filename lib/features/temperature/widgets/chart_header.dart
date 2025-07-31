import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import '../../../core/constants/chart_constants.dart';

class ChartHeader extends StatelessWidget {
  final String title;
  final DateTime maxTime;
  final bool showTimestamp;

  const ChartHeader({
    super.key,
    required this.title,
    required this.maxTime,
    this.showTimestamp = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: ChartConstants.headerLeftPadding,
        right: ChartConstants.headerRightPadding,
        bottom: ChartConstants.titleBottomSpacing,
      ),
      child: showTimestamp 
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: ChartConstants.titleSize,
                  color: Colors.white,
                ),
              ),
              Text(
                intl.DateFormat('yyyy-MM-dd HH:mm').format(maxTime.toLocal()),
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: ChartConstants.timestampSize,
                  color: Colors.white70,
                ),
              ),
            ],
          )
        : Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: ChartConstants.titleSize,
                color: Colors.white,
              ),
            ),
          ),
    );
  }
}
