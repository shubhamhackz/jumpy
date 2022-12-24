import 'dart:math';
import 'dart:ui';
import 'dart:ui' as ui show Gradient, lerpDouble;

import 'package:flame/components.dart';

class Ground extends PositionComponent {
  Ground()
      : pebbles = [],
        super(size: Vector2(1000, 50)) {
    final random = Random();
    for (var i = 0; i < 25; i++) {
      pebbles.add(
        Vector3(
          random.nextDouble() * size.x,
          random.nextDouble() * size.y / 3,
          random.nextDouble() * 0.5 + 1,
        ),
      );
    }
  }

  final Paint groundPaint = Paint()
    ..shader = ui.Gradient.linear(
      Offset.zero,
      const Offset(0, 30),
      [const Color(0xFFC9C972), const Color(0x22FFFF88)],
    );
  final Paint pebblePaint = Paint()..color = const Color(0xFF685A2B);

  final List<Vector3> pebbles;

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), groundPaint);
    for (final pebble in pebbles) {
      canvas.drawCircle(Offset(pebble.x, pebble.y), pebble.z, pebblePaint);
    }
  }
}
