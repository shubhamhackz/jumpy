part of 'responsive.dart';

/// Helper class for determining things like Device's
/// `height`, `width`, `aspect ratio`, `pixel ratio` and `orientation`
class ResponsiveHelper {
  /// Device's BoxConstraints
  static late BoxConstraints boxConstraints;

  /// Device's Orientation
  static late Orientation orientation;

  /// Type of Device
  static DeviceType deviceType = DeviceType.mobile;

  static late bool enableLandscape = false;

  /// Device's Height
  static late double height;

  /// Device's Width
  static late double width;

  /// Should use Pixel Density for calculating sp
  static late bool pixelDensity;

  static late Size uiSize;

  /// Gets Device's Aspect Ratio
  static double get aspectRatio {
    return WidgetsBinding.instance?.window.physicalSize.aspectRatio ?? 1;
  }

  /// Gets Device's Pixel Ratio
  static double get pixelRatio {
    return WidgetsBinding.instance?.window.devicePixelRatio ?? 1;
  }

  static double getScalablePixel() {
    // if (pixelDensity) {
    //   // Calculates the sp (Scalable Pixel) depending on the device's pixel density
    //   return (((height / 100 + width / 100) +
    //               (ResponsiveHelper.pixelRatio *
    //                   ResponsiveHelper.aspectRatio)) /
    //           2.08) /
    //       100;
    // } else {
    //   /// Calculates the sp (Scalable Pixel) depending on the device's screen size
    //   return (width / 3) / 100;
    // }
    if (ResponsiveHelper.pixelRatio >= 3.0) {
      return 0.4;
    } else if (ResponsiveHelper.pixelRatio >= 2.75) {
      return 0.3;
    } else {
      return 0.38;
    }
  }

  static set setUISize(Size size) {
    uiSize = size;
  }

  static double get scaleWidth => width / uiSize.width;

  static double get scaleHeight => width / uiSize.height;

  static double get scaleText => scaleWidth;

  static double setWidth(num width) => width * scaleWidth;

  static double setHeight(num height) => height * scaleHeight;

  static void setPixelDensity(bool value) {
    pixelDensity = value;
  }

  /// Sets the Screen's size and Device's Orientation,
  /// BoxConstraints, Height, and Width
  static void setScreenSize(
      BoxConstraints constraints, Orientation currentOrientation) {
    // Sets boxconstraints and orientation
    boxConstraints = constraints;
    orientation = currentOrientation;

    // Sets screen width and height
    if (orientation == Orientation.portrait) {
      width = boxConstraints.maxWidth;
      height = boxConstraints.maxHeight;
    } else {
      width = boxConstraints.maxHeight;
      height = boxConstraints.maxWidth;
    }

    /// Sets ScreenType by checking `Device's` width and height
    if (Platform.isAndroid || Platform.isIOS) {
      if ((orientation == Orientation.portrait && width < 600) ||
          (orientation == Orientation.landscape && height < 600)) {
        deviceType = DeviceType.mobile;
      } else {
        deviceType = DeviceType.tablet;
      }
    }
  }
}

/// Set DeviceType, this can be either mobile or tablet
enum DeviceType { mobile, tablet }
