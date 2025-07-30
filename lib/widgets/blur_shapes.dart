import 'dart:ui';
import 'package:flutter/material.dart';

/// Utility class for creating blurred shape widgets
class BlurShapes {
  /// Creates a circular blurred container with text
  static Widget circle({
    required String text,
    required String subtitle,
    Color? backgroundColor,
    required double width,
  }) {
    return SizedBox(
      width: width,
      height: width,
      child: ClipOval(
        clipBehavior: Clip.antiAlias,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 1.5,
            sigmaY: 1.5,
          ),
          child: Container(
            color: backgroundColor,
            padding: EdgeInsets.all(width / 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FractionallySizedBox(
                  widthFactor: 1,
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontFeatures: [FontFeature.proportionalFigures()],
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 25,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Creates a rectangular blurred container with text
  static Widget rectangle({
    required String text,
    Color? backgroundColor,
    required double width,
  }) {
    return SizedBox(
      width: width,
      child: ClipRect(
        clipBehavior: Clip.antiAlias,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 1.5,
            sigmaY: 1.5,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: width / 22,
              horizontal: width / 12,
            ),
            color: backgroundColor,
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(
                text,
                style: const TextStyle(
                  fontFeatures: [
                    FontFeature.proportionalFigures(),
                  ],
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}