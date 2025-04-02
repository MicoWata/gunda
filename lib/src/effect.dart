import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gunda/src/camera.dart';
import 'package:gunda/src/engine.dart';
import 'package:gunda/src/game.dart';
import 'package:gunda/src/mob.dart';
import 'package:gunda/src/state.dart';

class Effect {
  bool showSlowMotion = false;
  double slowMotionTimer = 0;
  final double maxSlowMotionTime = 30; // frames

  static void collide(CollisionInfo info) {
    // Create impact particles at collision point
    Effect.impact(
      info.collisionX,
      info.collisionY,
      Colors.white,
      info.impactEnergy,
      Game.state,
    );

    // Increment score based on impact energy
    Game.state.score += (Mob.value * info.impactEnergy / 2).ceil();

    // Activate slow motion for dramatic effect on powerful hits
    if (info.impactEnergy > 5) {
      Game.effect.showSlowMotion = true;
      Game.effect.slowMotionTimer = Game.effect.maxSlowMotionTime;
    }
  }

  static void impact(
    double x,
    double y,
    Color baseColor,
    double intensity,
    GameState gameState,
  ) {
    final particleCount = (intensity * 10).floor().clamp(5, 30);

    for (int i = 0; i < particleCount; i++) {
      final angle = Game.random.nextDouble() * 2 * pi;
      final speed = Game.random.nextDouble() * 5 * intensity;

      // Create color variations
      final colorVariation = Game.random.nextDouble() * 0.3;
      Color particleColor;
      if (Game.random.nextBool()) {
        particleColor =
            Color.lerp(baseColor, Colors.white, colorVariation) ?? baseColor;
      } else {
        particleColor =
            Color.lerp(baseColor, Colors.black, colorVariation) ?? baseColor;
      }

      gameState.impactParticles.add(
        ImpactParticle(
          x: x,
          y: y,
          xVelocity: cos(angle) * speed,
          yVelocity: sin(angle) * speed,
          size: 3 + Game.random.nextDouble() * 5,
          color: particleColor,
          lifespan: 20 + Game.random.nextDouble() * 30,
        ),
      );
    }
  }

  static Widget particles(
    double screenWidth,
    double screenHeight,
    GameState gameState,
    Camera camera,
  ) {
    return CustomPaint(
      size: Size(screenWidth, screenHeight),
      painter: ParticleSystemPainter(
        particles: gameState.impactParticles,
        cameraX: camera.x,
        cameraY: camera.y,
      ),
    );
  }
}

/// Particle class for impact effects
class ImpactParticle {
  double x;
  double y;
  double xVelocity;
  double yVelocity;
  double size;
  Color color;
  double opacity;
  double lifespan;

  ImpactParticle({
    required this.x,
    required this.y,
    required this.xVelocity,
    required this.yVelocity,
    required this.size,
    required this.color,
    this.opacity = 1.0,
    this.lifespan = 30, // frames
  });

  /// Update particle position and properties
  /// Returns true if particle is still alive
  bool update() {
    // Apply gravity
    yVelocity += 0.1;

    // Update position
    x += xVelocity;
    y += yVelocity;

    // Apply drag
    xVelocity *= 0.95;
    yVelocity *= 0.95;

    // Fade out
    opacity -= 1.0 / lifespan;

    // Shrink
    size -= size / lifespan;

    // Return true if particle is still alive
    return opacity > 0 && size > 0.5;
  }
}

/// Particle system painter for better performance
class ParticleSystemPainter extends CustomPainter {
  final List<ImpactParticle> particles;
  final double cameraX;
  final double cameraY;

  ParticleSystemPainter({
    required this.particles,
    this.cameraX = 0,
    this.cameraY = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      // Convert world coordinates to screen coordinates
      final screenX = particle.x - cameraX;
      final screenY = particle.y - cameraY;

      // Skip particles that are offscreen
      if (screenX < -particle.size ||
          screenX > size.width + particle.size ||
          screenY < -particle.size ||
          screenY > size.height + particle.size) {
        continue;
      }

      final paint =
          Paint()
            ..color = particle.color.withValues(alpha: particle.opacity)
            ..style = PaintingStyle.fill;

      // Draw particle
      canvas.drawCircle(Offset(screenX, screenY), particle.size / 2, paint);

      // Draw glow effect
      final glowPaint =
          Paint()
            ..color = particle.color.withValues(alpha: particle.opacity * 0.5)
            ..style = PaintingStyle.fill
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(
        Offset(screenX, screenY),
        particle.size / 2 + 1,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticleSystemPainter oldDelegate) {
    // Always repaint when particles change or camera moves
    return true;
  }
}
