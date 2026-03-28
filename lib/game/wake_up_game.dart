import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'obstacle.dart';
import 'obstacle_spawner.dart';
import 'player_car.dart';

/// The core mini-game required to dismiss the alarm.
///
/// Skill: @architecture — self-contained Flame game logic.
/// Skill: @flutter-expert — efficient rendering and state bridging via callbacks.
/// Skill: @frontend-design — dark theme base (#121212) with minimalistic text.
class WakeUpGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  WakeUpGame({
    required this.onMissionComplete,
    this.onTimeUpdate,
    this.onPointsUpdate,
  });

  /// Callback triggered when player survives for 30 seconds.
  final VoidCallback onMissionComplete;

  /// Optional: reports remaining time each frame to Flutter HUD layer.
  final ValueChanged<double>? onTimeUpdate;

  /// Optional: reports accumulated points to Flutter HUD layer.
  final ValueChanged<int>? onPointsUpdate;

  late PlayerCar _player;
  late RectangleComponent _flashOverlay;

  double _timeLeft = 30.0;
  int _points = 0;
  double _pointTimer = 0;
  bool isPlaying = true;

  @override
  Color backgroundColor() => const Color(0xFF121212); // Dark theme foundation

  @override
  Future<void> onLoad() async {
    super.onLoad();

    _player = PlayerCar(onCrash: _handleCrash);
    add(_player);
    add(ObstacleSpawner());

    // Flash Overlay
    _flashOverlay = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.red.withValues(alpha: 0.0),
    );
    add(_flashOverlay);
  }

  void _handleCrash() {
    if (!isPlaying) return;

    // Reset timer on hit
    _timeLeft = 30.0;
    onTimeUpdate?.call(_timeLeft);

    // Clear all existing obstacles to give player a fair restart
    children
        .whereType<Obstacle>()
        .forEach((obstacle) => obstacle.removeFromParent());

    // Reset the spawner speed
    children.whereType<ObstacleSpawner>().forEach((spawner) => spawner.reset());

    // Visual feedback: Red Flash
    _flashOverlay.paint.color = Colors.red.withValues(alpha: 0.3);
    _flashOverlay.add(
      OpacityEffect.to(
        0.0,
        EffectController(duration: 0.4),
      ),
    );

    // Visual feedback: Screen Shake
    camera.viewfinder.add(
      MoveEffect.by(
        Vector2(10, 10),
        EffectController(
          duration: 0.05,
          reverseDuration: 0.05,
          repeatCount: 3,
        ),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isPlaying) return;

    _timeLeft -= dt;

    // Award 1 point per second survived
    _pointTimer += dt;
    if (_pointTimer >= 1.0) {
      _pointTimer -= 1.0;
      _points++;
      onPointsUpdate?.call(_points);
    }

    if (_timeLeft <= 0) {
      _timeLeft = 0;
      isPlaying = false;
      onMissionComplete();
    }

    onTimeUpdate?.call(_timeLeft.clamp(0.0, 30.0));
  }


  /// Called from Flutter left-tap overlay.
  void tapLeft() {
    if (!isPlaying) return;
    final moveAmount = size.x / 4;
    _player.setTargetX(_player.targetX - moveAmount);
  }

  /// Called from Flutter right-tap overlay.
  void tapRight() {
    if (!isPlaying) return;
    final moveAmount = size.x / 4;
    _player.setTargetX(_player.targetX + moveAmount);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!isPlaying) return;

    // Determine if tap is on left or right half
    final isLeft = event.localPosition.x < size.x / 2;

    // Move target X by a chunk, clamped in the car logic
    final moveAmount = size.x / 4;
    final currentTarget = _player.targetX;

    if (isLeft) {
      _player.setTargetX(currentTarget - moveAmount);
    } else {
      _player.setTargetX(currentTarget + moveAmount);
    }
  }
}
