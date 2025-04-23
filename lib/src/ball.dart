import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gunda/src/body.dart';
import 'package:gunda/src/camera.dart';
import 'package:gunda/src/effect.dart';
import 'package:gunda/src/game.dart';
import 'package:gunda/src/level.dart';
import 'package:gunda/src/mob.dart';
import 'package:gunda/src/player.dart';

class Ball {
  static const double projectileRadius = 10.0;
  static const double projectileSpeed = 15.0; // Increased for larger map
  static const double projectileFriction =
      0.995; // Reduced friction for larger map
  static const double projectileAirResistance =
      0.998; // Reduced air resistance for larger map
  static const double projectileGravity = 0.05;
  static const double projectileWallBounce =
      0.7; // Increased bounce for larger map
  static const int maxProjectiles = 20; // More projectiles for larger map
  static const double mass = 1.0;

  static Widget buildBall(Projectile projectile, Camera camera) {
    return Positioned(
      left: projectile.x - projectile.radius - camera.x,
      top: projectile.y - projectile.radius - camera.y,
      child: Container(
        width: projectile.radius * 2,
        height: projectile.radius * 2,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [projectile.color, projectile.color.withValues(alpha: 0.7)],
            stops: const [0.3, 1.0],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color:
                  projectile.isPlayerProjectile
                      ? projectile.color.withValues(
                        alpha: 0.5,
                      ) // Player projectile glow
                      : Colors.redAccent.withValues(
                        alpha: 0.4,
                      ), // Enemy projectile glow
              blurRadius: projectile.isPlayerProjectile ? 10 : 8,
              spreadRadius: projectile.isPlayerProjectile ? 2 : 1,
            ),
          ],
          // Add a border for enemy projectiles to make them more distinct
          border:
              projectile.isPlayerProjectile
                  ? null
                  : Border.all(
                    color: Colors.redAccent.withValues(alpha: 0.7),
                    width: 1.5,
                  ),
        ),
      ),
    );
  }

  static Widget buildCombinedTrails(
    double screenWidth,
    double screenHeight,
    Camera camera,
  ) {
    return CustomPaint(
      size: Size(screenWidth, screenHeight),
      painter: CombinedTrailsPainter(
        projectiles: Level.projectiles,
        cameraX: camera.x,
        cameraY: camera.y,
      ),
    );
  }

  // Handle player projectile collision with enemy
  static void handleProjectileEnemyCollision(
    Projectile projectile,
    Body enemy,
    int projectileIndex,
    int enemyIndex,
  ) {
    // Calculate collision response vector
    final collisionNormalX = projectile.x - enemy.centerX;
    final collisionNormalY = projectile.y - enemy.centerY;

    // Normalize the collision vector
    final magnitude = sqrt(
      collisionNormalX * collisionNormalX + collisionNormalY * collisionNormalY,
    );

    final normalizedX = collisionNormalX / magnitude;
    final normalizedY = collisionNormalY / magnitude;

    // Calculate impact force based on projectile energy
    final impactForce = projectile.energy * 0.08; // Stronger impact on enemies

    // Apply force to enemy with conservation of momentum
    final impulseX = normalizedX * impactForce;
    final impulseY = normalizedY * impactForce;

    // Apply impulse to enemy
    enemy.applyImpulse(impulseX, impulseY);

    // Create impact particles
    Effect.impact(
      projectile.x,
      projectile.y,
      Colors.deepOrange, // More intense color for enemy hits
      impactForce,
    );

    // Activate slow motion for dramatic effect on powerful hits
    //if (impactForce > 8) {
    //  Game.effect.showSlowMotion = true;
    //  Game.effect.slowMotionTimer = Game.effect.maxSlowMotionTime;
    //}

    // Increment score more for enemy hits
    Game.score += (Mob.value * impactForce / 2).ceil();

    // Remove the projectile
    if (projectileIndex >= 0 && projectileIndex < Level.projectiles.length) {
      //setState(() {
      Level.projectiles.removeAt(projectileIndex);
      //});
    }
  }

  // Handle enemy projectile collision with player
  static void handleProjectilePlayerCollision(
    Projectile projectile,
    int projectileIndex,
  ) {
    // Calculate collision response vector
    final collisionNormalX = projectile.x - Player.body.centerX;
    final collisionNormalY = projectile.y - Player.body.centerY;

    // Normalize the collision vector
    final magnitude = sqrt(
      collisionNormalX * collisionNormalX + collisionNormalY * collisionNormalY,
    );

    final normalizedX = collisionNormalX / magnitude;
    final normalizedY = collisionNormalY / magnitude;

    // Calculate impact force based on projectile energy
    final impactForce = projectile.energy * 0.1; // Strong impact on player

    // Apply force to player with conservation of momentum
    final impulseX = normalizedX * impactForce;
    final impulseY = normalizedY * impactForce;

    // Apply impulse to player
    Player.body.applyImpulse(impulseX, impulseY);

    // Create impact particles with orange/red to indicate damage
    Effect.impact(
      projectile.x,
      projectile.y,
      Colors.red.withValues(alpha: 0.8), // Red color for player damage
      impactForce * 1.2, // More dramatic effect
    );

    // Activate slow motion for dramatic effect
    if (impactForce > 5) {
      Game.effect.showSlowMotion = true;
      Game.effect.slowMotionTimer = Game.effect.maxSlowMotionTime;
    }

    // Reduce player lives if hit is strong enough
    if (!Game.over) {
      Player.lives = Player.lives - 1;

      // Check for game over
      if (Player.lives < 1) {
        Game.over = true;
        Game.animationController.stop();
      }
    }

    // Remove the projectile
    if (projectileIndex >= 0 && projectileIndex < Level.projectiles.length) {
      //setState(() {
      Level.projectiles.removeAt(projectileIndex);
      //});
    }
  }
}

// Projectile class for physics-based projectiles
class Projectile {
  double x;
  double y;
  double xVelocity;
  double yVelocity;
  final double radius;
  final Color color;
  final double mass;
  bool isActive = true;
  bool canExplode = false;
  int bounceCount = 0;

  // Track if projectile was fired by player or enemy
  final bool isPlayerProjectile;

  /// Trail points to show projectile path
  final List<Offset> trail = [];
  final int maxTrailPoints = 10;

  Projectile({
    required this.x,
    required this.y,
    required this.xVelocity,
    required this.yVelocity,
    required this.radius,
    required this.color,
    required this.canExplode,
    this.mass = Ball.mass,
    this.isPlayerProjectile = true, // Default to player projectile
  });

  void explode() {
    const double explosionRadius = 300;
    const double explosionForce = 50;

    // Apply area of effect (AOE) force to nearby objects
    for (final entity in Level.enemies) {
      final dx = entity.body.centerX - x;
      final dy = entity.body.centerY - y;
      final distance = sqrt(dx * dx + dy * dy);

      if (distance < explosionRadius && distance > 0) {
        final force = explosionForce * (1 - distance / explosionRadius);
        final nx = dx / distance;
        final ny = dy / distance;

        entity.body.applyImpulse(nx * force, ny * force);

        if (entity.hp != null) {
          entity.hurt();
          if (entity.hp <= 0) {
            entity.die(); // Or however you remove enemies
          }
        }
      }
    }
    // Add visual effect
    Effect.explosion(x, y, explosionRadius, color);

    // Remove the projectile
    Level.projectiles.remove(this);
  }

  /// Update projectile position based on velocity
  void update(Size screenSize) {
    // Record position for trail
    if (trail.length >= maxTrailPoints) {
      trail.removeAt(0);
    }
    trail.add(Offset(x, y));

    // Apply physics
    _applyPhysics(screenSize);

    // Update position
    x += xVelocity;
    y += yVelocity;

    // Handle wall collisions
    _handleWallCollisions(screenSize);
  }

  /// Apply physics calculations to the projectile
  void _applyPhysics(Size screenSize) {
    // Apply gravity
    //yVelocity += Ball.projectileGravity;

    // Apply air resistance
    xVelocity *= Ball.projectileAirResistance;
    yVelocity *= Ball.projectileAirResistance;

    // Apply ground friction when touching bottom
    if (y >= screenSize.height - radius && yVelocity.abs() < 1.0) {
      xVelocity *= Ball.projectileFriction;
    }
  }

  /// Handle collisions with screen boundaries
  void _handleWallCollisions(Size screenSize) {
    if (x <= radius) {
      x = radius;
      xVelocity = -xVelocity * Ball.projectileWallBounce;
      bounceCount++;
    } else if (x >= screenSize.width - radius) {
      x = screenSize.width - radius;
      xVelocity = -xVelocity * Ball.projectileWallBounce;
      bounceCount++;
    }

    if (y <= radius) {
      y = radius;
      yVelocity = -yVelocity * Ball.projectileWallBounce;
      bounceCount++;
    } else if (y >= screenSize.height - radius) {
      y = screenSize.height - radius;
      yVelocity = -yVelocity * Ball.projectileWallBounce;
      bounceCount++;
    }

    if (canExplode && bounceCount > 0) {
      final impactSpeed = sqrt(xVelocity * xVelocity + yVelocity * yVelocity);
      if (impactSpeed > 2.0) {
        explode();
      }
    }
  }

  /// Check if projectile collides with a rectangle
  bool collidesWith(Body rect) {
    // Find closest point on rectangle to circle center
    final closestX = x.clamp(rect.left, rect.right);
    final closestY = y.clamp(rect.top, rect.bottom);

    // Calculate distance from closest point to circle center
    final distanceX = x - closestX;
    final distanceY = y - closestY;
    final distanceSquared = distanceX * distanceX + distanceY * distanceY;

    // Circle collides if the distance is less than the radius
    return distanceSquared <= (radius * radius);
  }

  /// Get the total kinetic energy of the projectile
  double get energy {
    final speed = sqrt(xVelocity * xVelocity + yVelocity * yVelocity);
    return 0.5 * mass * speed * speed;
  }

  /// Apply impulse (change in momentum) to the projectile
  void applyImpulse(double forceX, double forceY) {
    xVelocity += forceX / mass;
    yVelocity += forceY / mass;
  }

  /// Convert Projectile object to a JSON map
  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
        'xVelocity': xVelocity,
        'yVelocity': yVelocity,
        'radius': radius,
        'color': color.value,
        'mass': mass,
        'isActive': isActive,
        'canExplode': canExplode,
        'bounceCount': bounceCount,
        'isPlayerProjectile': isPlayerProjectile,
        'trail': trail.map((offset) => {'dx': offset.dx, 'dy': offset.dy}).toList(),
      };

  /// Create Projectile object from a JSON map
  factory Projectile.fromJson(Map<String, dynamic> json) {
    final projectile = Projectile(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      xVelocity: (json['xVelocity'] as num).toDouble(),
      yVelocity: (json['yVelocity'] as num).toDouble(),
      radius: (json['radius'] as num).toDouble(),
      color: Color(json['color'] as int),
      mass: (json['mass'] as num).toDouble(),
      canExplode: json['canExplode'] as bool,
      isPlayerProjectile: json['isPlayerProjectile'] as bool,
    )
      ..isActive = json['isActive'] as bool
      ..bounceCount = json['bounceCount'] as int;

    // Restore trail
    if (json['trail'] != null) {
      projectile.trail.addAll(
        (json['trail'] as List)
            .map((point) => Offset(
                  (point['dx'] as num).toDouble(),
                  (point['dy'] as num).toDouble(),
                ))
            .toList(),
      );
    }
    return projectile;
  }
}

/// Combined trails painter for better performance
class CombinedTrailsPainter extends CustomPainter {
  final List<Projectile> projectiles;
  final double cameraX;
  final double cameraY;

  CombinedTrailsPainter({
    required this.projectiles,
    this.cameraX = 0,
    this.cameraY = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final projectile in projectiles) {
      // Skip if trail is too short
      if (projectile.trail.length < 2) continue;

      // Draw trail segments with fading opacity
      for (int i = 0; i < projectile.trail.length - 1; i++) {
        final worldStart = projectile.trail[i];
        final worldEnd = projectile.trail[i + 1];

        // Convert to screen coordinates
        final start = Offset(worldStart.dx - cameraX, worldStart.dy - cameraY);
        final end = Offset(worldEnd.dx - cameraX, worldEnd.dy - cameraY);

        final progress = i / (projectile.trail.length - 1);

        // Different trail styles for player vs enemy projectiles
        Color trailColor;
        double opacity;
        double width;

        if (projectile.isPlayerProjectile) {
          // Player projectiles: normal trails
          trailColor = projectile.color;
          opacity = 0.3 * progress;
          width = 3 * progress;
        } else {
          // Enemy projectiles: reddish trails
          trailColor = projectile.color.withRed(
            ((projectile.color.r * 1.3).clamp(0, 255)).toInt(),
          );
          opacity = 0.4 * progress; // More visible
          width = 2.5 * progress; // Slightly thinner
        }

        final paint =
            Paint()
              ..color = trailColor.withValues(alpha: opacity)
              ..strokeWidth = width
              ..strokeCap = StrokeCap.round;

        canvas.drawLine(start, end, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CombinedTrailsPainter oldDelegate) {
    // Always repaint when projectiles change or camera moves
    return true;
  }
}
