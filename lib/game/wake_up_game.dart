import 'package:flame/components.dart';
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
class WakeUpGame extends FlameGame 
    with TapCallbacks, HasCollisionDetection {
  
  WakeUpGame({required this.onMissionComplete});

  /// Callback triggered when player survives for 30 seconds.
  final VoidCallback onMissionComplete;

  late PlayerCar _player;
  late TextComponent _timerText;
  
  double _timeLeft = 30.0;
  bool isPlaying = true;

  @override
  Color backgroundColor() => const Color(0xFF121212); // Dark theme foundation

  @override
  Future<void> onLoad() async {
    super.onLoad();

    _player = PlayerCar(onCrash: _handleCrash);
    add(_player);
    add(ObstacleSpawner());

    // Timer UI
    _timerText = TextComponent(
      text: '30.0',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFB026FF), // Neon Purple
          fontSize: 48,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
    // Position timer at top center
    _timerText.anchor = Anchor.topCenter;
    _timerText.position = Vector2(size.x / 2, 60);
    add(_timerText);
  }

  void _handleCrash() {
    if (!isPlaying) return;
    
    // Reset timer on hit
    _timeLeft = 30.0;
    
    // Clear all existing obstacles to give player a fair restart
    children.whereType<Obstacle>().forEach((obstacle) => obstacle.removeFromParent());
    
    // Reset the spawner speed
    children.whereType<ObstacleSpawner>().forEach((spawner) => spawner.reset());

    // Add visual feedback (flash screen red then back)
    // For simplicity in a self-contained FlameGame without robust effect chaining,
    // we'll just update the text immediately to show the reset penalty.
    _updateTimerText();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isPlaying) return;

    _timeLeft -= dt;

    if (_timeLeft <= 0) {
      _timeLeft = 0;
      isPlaying = false;
      onMissionComplete();
    }

    _updateTimerText();
  }

  void _updateTimerText() {
    final displayTime = _timeLeft.clamp(0.0, 30.0);
    _timerText.text = displayTime.toStringAsFixed(1);
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
