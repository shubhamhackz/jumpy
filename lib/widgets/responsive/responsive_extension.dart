part of 'responsive.dart';

extension ResponsiveExtension on num {
  /// Calculates the height depending on the device's screen size
  /// Eg: 10.h -> will take 10% of the screen's height
  double get h => this * ResponsiveHelper.height / 100;

  /// Calculates the width depending on the device's screen size
  /// Eg: 10.w -> will take 10% of the screen's width
  double get w => this * ResponsiveHelper.width / 100;

  /// Calculates the sp (Scalable Pixel) depending on the device's pixel density
  double get sp =>
      this * ResponsiveHelper.scaleText -
      (this * ResponsiveHelper.getScalablePixel());
}
