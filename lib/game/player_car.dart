import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'wake_up_game.dart';

/// The player's vehicle.
///
/// Skill: @frontend-design — neon purple, cleanly drawn.
/// Skill: @architecture — clear collision boundaries, distinct component.
class PlayerCar extends PositionComponent
    with HasGameReference<WakeUpGame>, CollisionCallbacks {
  PlayerCar({this.onCrash}) : super(size: Vector2(40, 70));

  final VoidCallback? onCrash;

  final _paint = Paint()..color = const Color(0xFFB026FF); // Neon Purple
  final _glowPaint = Paint()
    ..color = const Color(0x33B026FF)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

  /// Target X position for smooth horizontal movement.
  double _targetX = 0;
  static const double _speed = 400.0;

  @override
  void onLoad() {
    super.onLoad();
    // Anchor to center for easier positioning
    anchor = Anchor.center;
    // Initial position at bottom center
    position = Vector2(game.size.x / 2, game.size.y - 100);
    _targetX = position.x;

    // Add a hitbox for collision detection with active collision type
    add(RectangleHitbox(size: size)..collisionType = CollisionType.active);
  }

  @override
  void render(Canvas canvas) {
    // Draw main glow (outer)
    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect(), const Radius.circular(8)),
      _glowPaint,
    );

    // Draw inner bright neon stroke
    final strokePaint = Paint()
      ..color = const Color(0xFFE0B0FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect(), const Radius.circular(8)),
      strokePaint,
    );

    // Draw car body
    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect(), const Radius.circular(8)),
      _paint,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Smooth movement towards target X
    if ((_targetX - position.x).abs() > 2) {
      final direction = (_targetX > position.x) ? 1.0 : -1.0;
      position.x += direction * _speed * dt;
    } else {
      position.x = _targetX;
    }
    
    // Clamp to screen bounds
    position.x = position.x.clamp(size.x / 2, game.size.x - size.x / 2).toDouble();
  }

  /// Expose the current target X for subsequent tap calculations
  double get targetX => _targetX;

  /// Sets the target X coordinate for steering.
  void setTargetX(double x) {
    _targetX = x;
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is! PlayerCar) {
      onCrash?.call();
    }
    super.onCollisionStart(intersectionPoints, other);
  }
}
