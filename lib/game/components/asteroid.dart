import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'bullet.dart';
import 'explosion_particle.dart';
import 'ship.dart';
import '../space_shooter_game.dart';

class Asteroid extends PositionComponent with HasGameReference<SpaceShooterGame>, CollisionCallbacks {
  Asteroid() : super(size: Vector2(50, 50), anchor: Anchor.center);

  final double speed = 150.0;

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += speed * dt;

    if (position.y > game.size.y + size.y) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.orangeAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final glowPaint = Paint()
      ..color = Colors.orangeAccent.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, glowPaint);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, paint);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is Bullet) {
      other.removeFromParent();
      removeFromParent();
      game.addScore();
      game.add(ExplosionParticle(position.clone()));
    } else if (other is Ship) {
      removeFromParent();
      game.hitAsteroid();
      game.add(ExplosionParticle(position.clone()));
    }
  }
}
