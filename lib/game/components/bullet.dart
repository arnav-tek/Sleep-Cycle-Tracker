import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../space_shooter_game.dart';

class Bullet extends PositionComponent with HasGameReference<SpaceShooterGame> {
  Bullet() : super(size: Vector2(6, 20), anchor: Anchor.center);

  final double speed = 400.0;

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y -= speed * dt;

    if (position.y < -size.y) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.white;
    final glowPaint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRect(rect, glowPaint);
    canvas.drawRect(rect, paint);
  }
}
