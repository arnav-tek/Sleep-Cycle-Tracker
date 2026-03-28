import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'wake_up_game.dart';

/// An enemy block that moves downwards.
///
/// Skill: @architecture — modular component, manages its own lifecycle.
/// Skill: @frontend-design — distinct visual contrast against dark UI.
class Obstacle extends PositionComponent with HasGameReference<WakeUpGame> {
  Obstacle({required this.speed, Vector2? sizeOverride})
      : super(size: sizeOverride ?? Vector2(50, 50));

  final double speed;
  final _paint = Paint()
    ..color = const Color(0xFFE0E0E0); // Off-white for contrast against #121212

  @override
  void onLoad() {
    super.onLoad();
    anchor = Anchor.center;
    add(RectangleHitbox(size: size));
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect(), const Radius.circular(4)),
      _paint,
    );

    // Add a gloss highlight
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(4, 4, size.x - 8, 4),
        const Radius.circular(2),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.5),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move downwards slowly
    position.y += speed * dt;

    // Remove if off screen
    if (position.y > game.size.y + size.y) {
      removeFromParent();
    }
  }
}
