import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

class ExplosionParticle extends ParticleSystemComponent {
  ExplosionParticle(Vector2 position)
      : super(
          position: position,
          particle: Particle.generate(
            count: 20,
            lifespan: 0.5,
            generator: (i) {
              final rnd = Random();
              return AcceleratedParticle(
                acceleration: Vector2(0, 0),
                speed: Vector2((rnd.nextDouble() - 0.5) * 300,
                    (rnd.nextDouble() - 0.5) * 300),
                position: Vector2.zero(),
                child: CircleParticle(
                  radius: rnd.nextDouble() * 3 + 1,
                  paint: Paint()
                    ..color = Colors.orangeAccent.withValues(alpha: 0.8)
                    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
                ),
              );
            },
          ),
        );
}
