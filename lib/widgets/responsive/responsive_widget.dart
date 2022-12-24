part of 'responsive.dart';

typedef ResponsiveBuild = Widget Function(
  BuildContext context,
  Orientation orientation,
  DeviceType deviceType,
);

/// Sets the device's details like orientation and constraints
/// `Note` Wrap MaterialWidget with ResponsiveWidget
class ResponsiveWidget extends StatelessWidget {
  const ResponsiveWidget({
    Key? key,
    required this.builder,
    required this.pixelDensity,
    required this.designUISize,
  }) : super(key: key);

  final ResponsiveBuild builder;
  final bool pixelDensity;
  final Size designUISize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return OrientationBuilder(
          builder: (context, orientation) {
            /// Set the screen size
            ResponsiveHelper.setScreenSize(constraints, orientation);

            /// Set if pixel density to be used for calculating sp
            ResponsiveHelper.setPixelDensity(pixelDensity);

            ResponsiveHelper.setUISize = designUISize;

            /// return the builder method passed onto RespossiveWidget
            return builder(context, orientation, ResponsiveHelper.deviceType);
          },
        );
      },
    );
  }
}
