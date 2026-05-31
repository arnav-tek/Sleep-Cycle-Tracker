import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../space_shooter_game.dart';

class HudComponent extends PositionComponent with HasGameReference<SpaceShooterGame> {
  HudComponent() : super(priority: 100);

  double timeLeft = 30.0;
  int score = 0;
  int lives = 3;

  late TextPaint _textPaint;
  late TextPaint _scorePaint;

  @override
  Future<void> onLoad() async {
    _textPaint = TextPaint(
      style: GoogleFonts.spaceGrotesk(
        fontSize: 24,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
    _scorePaint = TextPaint(
      style: GoogleFonts.spaceGrotesk(
        fontSize: 20,
        color: Colors.cyanAccent,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  void updateTime(double t) {
    timeLeft = t;
  }

  void updateScore(int s) {
    score = s;
  }

  void updateLives(int l) {
    lives = l;
  }

  @override
  void render(Canvas canvas) {
    final displaySeconds = timeLeft.ceil();
    _textPaint.render(
      canvas,
      '00:${displaySeconds.toString().padLeft(2, '0')}',
      Vector2(20, 60),
    );

    _scorePaint.render(
      canvas,
      'Score: $score/50',
      Vector2(game.size.x - 20, 60),
      anchor: Anchor.topRight,
    );

    // Draw hearts
    final heartPaint = Paint()..color = Colors.redAccent;
    final heartPaintEmpty = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < 3; i++) {
      final x = game.size.x / 2 - 30 + i * 30;
      const y = 70.0;
      if (i < lives) {
        canvas.drawCircle(Offset(x, y), 8, heartPaint);
      } else {
        canvas.drawCircle(Offset(x, y), 8, heartPaintEmpty);
      }
    }
  }
}
