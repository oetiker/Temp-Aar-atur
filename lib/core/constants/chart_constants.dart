/// Chart-specific constants for temperature data visualization
class ChartConstants {
  // Spacing values - optimized for tighter layout
  static const double titleTopSpacing = 5.0;        // Reduced from 20px - space above title
  static const double titleBottomSpacing = 3.0;     // Reduced from 15px - title to chart gap
  static const double chartTopMargin = 5.0;         // Reduced from 10px - chart container top
  static const double chartBottomMargin = 10.0;     // Chart container bottom
  static const double chartLeftMargin = 10.0;       // Chart container left
  static const double chartRightMargin = 10.0;      // Chart container right
  
  // Chart internal padding
  static const double chartInsetLeft = 12.0;        // Chart content left padding
  static const double chartInsetTop = 6.0;          // Chart content top padding  
  static const double chartInsetRight = 6.0;        // Chart content right padding
  static const double chartInsetBottom = 10.0;      // Chart content bottom padding
  
  // Chart text sizing
  static const double titleSize = 20.0;
  static const double timestampSize = 12.0;
  static const double labelSize = 12.0;
  
  // Chart header padding
  static const double headerLeftPadding = 70.0;     // Align with chart content
  static const double headerRightPadding = 20.0;    // Right side padding
  
  // Grid styling constants
  static const double majorGridAlpha = 0.5;         // Major grid line opacity
  static const double minorGridAlpha = 0.4;         // Minor grid line opacity
  static const double majorGridWidth = 0.8;         // Major grid line thickness
  static const double minorGridWidth = 0.5;         // Minor grid line thickness
  
  // Background panel styling
  static const double backgroundAlpha = 0.5;        // Chart background opacity
  static const double borderRadius = 2.0;           // Background corner radius
  
  // Axis styling
  static const double axisLineWidth = 1.0;          // Axis line thickness
  static const double tickLineLength = 4.0;         // Tick mark length
  static const double labelOffsetX = 10.0;          // Time label offset
  static const double labelOffsetY = -10.0;         // Temperature label offset
  
  // Temperature display scaling factors
  static const double airTempCircleFactor = 2.3;
  static const double waterTempCircleFactor = 0.6;
  static const double batteryInfoWidthFactor = 0.3;
}
