import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'bullet.dart';
import '../space_shooter_game.dart';

class Ship extends PositionComponent with HasGameReference<SpaceShooterGame> {
  Ship() : super(size: Vector2(40, 60), anchor: Anchor.center);

  double _fireTimer = 0;
  final double _fireInterval = 0.3;

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    _fireTimer += dt;
    if (_fireTimer >= _fireInterval) {
      _fireTimer = 0;
      final bullet = Bullet()
        ..position = position.clone() - Vector2(0, size.y / 2);
      game.add(bullet);
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.cyanAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path()
      ..moveTo(size.x / 2, 0)
      ..lineTo(size.x, size.y)
      ..lineTo(size.x / 2, size.y * 0.8)
      ..lineTo(0, size.y)
      ..close();

    final glowPaint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
  }
}
