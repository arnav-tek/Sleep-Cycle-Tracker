import 'dart:math';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'components/asteroid.dart';
import 'components/hud_component.dart';
import 'components/ship.dart';

class SpaceShooterGame extends FlameGame with PanDetector, HasCollisionDetection {
  SpaceShooterGame({
    required this.onMissionComplete,
  });

  final VoidCallback onMissionComplete;

  late Ship ship;
  late HudComponent hud;
  
  double timeLeft = 30.0;
  int score = 0;
  int lives = 3;
  bool _isGameOver = false;

  final Random _rng = Random();
  double _spawnTimer = 0.0;
  final double _spawnInterval = 1.0; // spawn slightly faster to ensure enough targets

  @override
  Color backgroundColor() => const Color(0xFF0E0E0E);

  @override
  Future<void> onLoad() async {
    super.onLoad();

    ship = Ship()..position = Vector2(size.x / 2, size.y - 120);
    add(ship);

    hud = HudComponent();
    add(hud);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (_isGameOver) return;
    ship.position.x += info.delta.global.x;
    // clamp ship inside screen
    ship.position.x = ship.position.x.clamp(ship.size.x / 2, size.x - ship.size.x / 2);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isGameOver) return;

    timeLeft -= dt;
    if (timeLeft <= 0) {
      // Reset timer, clear asteroids, don't lose lives or score (forgiving mode)
      timeLeft = 30.0;
      _clearAsteroids();
    }

    hud.updateTime(timeLeft);
    hud.updateScore(score);
    hud.updateLives(lives);

    if (score >= 50) {
      _isGameOver = true;
      onMissionComplete();
      return;
    }

    _spawnTimer += dt;
    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0;
      _spawnAsteroid();
    }
  }

  void _spawnAsteroid() {
    final x = _rng.nextDouble() * (size.x - 40) + 20;
    final asteroid = Asteroid()
      ..position = Vector2(x, -50);
    add(asteroid);
  }

  void _clearAsteroids() {
    children.whereType<Asteroid>().forEach((a) => a.removeFromParent());
  }

  void hitAsteroid() {
    lives--;
    score = 0;
    if (lives <= 0) {
      lives = 3;
    }
  }

  void addScore() {
    score += 10;
  }
}
