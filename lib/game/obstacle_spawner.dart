import 'dart:math';
import 'package:flame/components.dart';

import 'obstacle.dart';
import 'wake_up_game.dart';

/// Spawns obstacles down the screen at increasing speeds.
///
/// Skill: @architecture — separates spawning logic from main game class.
class ObstacleSpawner extends Component with HasGameReference<WakeUpGame> {
  final _random = Random();

  /// Starting speed of obstacles.
  double _currentSpeed = 300;

  /// Base time between spawns.
  double _spawnInterval = 1.0;
  double _timeSinceLastSpawn = 0;

  void reset() {
    _currentSpeed = 300;
    _spawnInterval = 1.0;
    _timeSinceLastSpawn = 0;
  }

  void _spawnObstacle() {
    if (!game.isPlaying) return;

    // Pick a random X within screen width
    const double padding = 30.0;
    final double randomX =
        padding + _random.nextDouble() * (game.size.x - padding * 2);

    // Randomize size between 30 and 70
    final double randomSize = 30.0 + _random.nextDouble() * 40.0;

    final obstacle =
        Obstacle(speed: _currentSpeed, sizeOverride: Vector2.all(randomSize))
          ..position = Vector2(randomX, -70);

    // Add to game
    game.add(obstacle);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.isPlaying) return;

    _timeSinceLastSpawn += dt;
    if (_timeSinceLastSpawn >= _spawnInterval) {
      _spawnObstacle();
      _timeSinceLastSpawn = 0;
    }

    // Gradually increase speed over time
    _currentSpeed += 10.0 * dt;

    // Gradually decrease spawn interval up to a limit
    if (_spawnInterval > 0.4) {
      _spawnInterval -= 0.02 * dt;
    }
  }
}
