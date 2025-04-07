import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gunda/src/ball.dart';
import 'package:gunda/src/body.dart';
import 'package:gunda/src/camera.dart';
import 'package:gunda/src/effect.dart';
import 'package:gunda/src/engine.dart';
import 'package:gunda/src/game.dart';
import 'package:gunda/src/level.dart';
import 'package:gunda/src/obstacle.dart';
import 'package:gunda/src/player.dart';
import 'package:gunda/src/weapon.dart';

class Mob {
  static double value = 1;
  static Size size = Size(100, 80);
  static double mass = 2.6;
  static int count = 6;
  static int max = 3;
  static int remaining = count;
  static int hp = 3;
  static int cooldown = 1000;

  static void _handleEnemyShooting(Enemy enemy, int enemyIndex) {
    // Check if enemy can shoot (based on cooldown)
    if (enemy.canShoot) {
      // Calculate distance to player
      final dx = Player.body.centerX - enemy.body.centerX;
      final dy = Player.body.centerY - enemy.body.centerY;
      final distanceToPlayer = sqrt(dx * dx + dy * dy);

      // Only shoot if within range and not too close
      final shootingRange = 600.0; // Maximum shooting range
      final minShootingRange = 100.0; // Don't shoot if too close

      if (distanceToPlayer <= shootingRange &&
          distanceToPlayer >= minShootingRange) {
        // Random chance to shoot (more likely if player is closer)
        final shootChance =
            (shootingRange - distanceToPlayer) /
            shootingRange *
            0.04; // 4% max chance per frame

        if (Game.random.nextDouble() < shootChance) {
          _enemyShoot(enemy, enemyIndex);
        }
      }
    } else {
      // Decrease cooldown timer
      enemy.cooldown -= 16; // Assume ~60fps, so ~16ms per frame

      // Reset cooldown if timer is done
      if (enemy.cooldown <= 0) {
        enemy.canShoot = true;
      }
    }
  }

  // Create and fire a projectile from enemy toward player
  static void _enemyShoot(Enemy enemy, int enemyIndex) {
    // Calculate direction from enemy to player
    final enemyCenterX = enemy.body.centerX;
    final enemyCenterY = enemy.body.centerY;

    // Vector from enemy to player
    final dx = Player.body.centerX - enemyCenterX;
    final dy = Player.body.centerY - enemyCenterY;

    // Normalize the vector
    final distance = sqrt(dx * dx + dy * dy);

    if (distance > 0) {
      final normalizedDx = dx / distance;
      final normalizedDy = dy / distance;

      // Add some randomness to enemy aim (accuracy decreases with distance)
      final accuracy =
          0.95 -
          (distance /
              2000.0); // Accuracy between 95% and ~75% based on distance
      final randomFactor = 1.0 - accuracy;

      final randomAngle =
          (Game.random.nextDouble() * 2 - 1) *
          randomFactor *
          0.2; // Max ±0.2 radians (±11.5 degrees)
      final finalDx =
          normalizedDx * cos(randomAngle) - normalizedDy * sin(randomAngle);
      final finalDy =
          normalizedDx * sin(randomAngle) + normalizedDy * cos(randomAngle);

      // Generate power level (enemies shoot with less power than player can)
      final enemyPowerLevel =
          Weapon.minPower +
          Game.random.nextDouble() *
              (Weapon.maxPower - Weapon.minPower) *
              0.7; // Up to 70% of max power

      // Create projectile color based on enemy's color
      final projectileColor = enemy.body.color.withValues(alpha: 0.8);

      // Create projectile
      final projectile = Projectile(
        x: enemyCenterX,
        y: enemyCenterY,
        xVelocity: finalDx * enemyPowerLevel,
        yVelocity: finalDy * enemyPowerLevel,
        radius: Ball.projectileRadius * 0.8, // Slightly smaller projectiles
        color: projectileColor,
        mass: Ball.mass * 0.7, // Slightly lighter projectiles
        isPlayerProjectile: false, // Enemy projectile
      );

      // Apply recoil to enemy
      final recoilForce = enemyPowerLevel * Ball.mass / enemy.body.mass;
      enemy.body.applyImpulse(
        -finalDx * recoilForce * 1.5, // Less recoil than player
        -finalDy * recoilForce * 1.5,
      );

      //setState(() {
      Level.projectiles.add(projectile);

      enemy.canShoot = false;
      enemy.cooldown = Mob.cooldown;

      // Create particle effect at launch position
      Effect.impact(
        enemyCenterX,
        enemyCenterY,
        projectileColor.withRed(
          ((projectileColor.r * 1.3).clamp(0, 255)).toInt(),
        ),
        (enemyPowerLevel / Weapon.maxPower) * 0.8, // Smaller effect than player
      );
      //});
    }
  }

  // Handle enemy wall collisions
  static void _handleEnemyWallCollisions(Body enemy) {
    // Keep enemy within game boundaries with bounce
    if (enemy.x <= 0) {
      enemy.x = 0;
      enemy.xVelocity = -enemy.xVelocity * Engine.wallBounce;
    } else if (enemy.x >= Level.size.width - enemy.width) {
      enemy.x = Level.size.width - enemy.width;
      enemy.xVelocity = -enemy.xVelocity * Engine.wallBounce;
    }

    if (enemy.y <= 0) {
      enemy.y = 0;
      enemy.yVelocity = -enemy.yVelocity * Engine.wallBounce;
    } else if (enemy.y >= Game.gameHeight - enemy.height) {
      enemy.y = Game.gameHeight - enemy.height;
      enemy.yVelocity = -enemy.yVelocity * Engine.wallBounce;
    }
  }

  // Apply different AI behaviors to enemies
  static void _applyEnemyAI(Body enemy, int index) {
    // Different behaviors for each enemy
    switch (index % 3) {
      case 0: // First enemy chases player aggressively
        _applyChaseAI(enemy, 1.5);
        break;
      case 1: // Second enemy circles the player
        _applyCirclingAI(enemy);
        break;
      case 2: // Third enemy moves erratically
        _applyErraticAI(enemy);
        break;
    }
  }

  // Enemy AI: Circle around the player with obstacle avoidance
  static void _applyCirclingAI(Body enemy) {
    final dx = Player.body.centerX - enemy.centerX;
    final dy = Player.body.centerY - enemy.centerY;
    final distance = sqrt(dx * dx + dy * dy);

    // Ideal distance to circle at
    final idealDistance = 250.0;

    if (distance > 0) {
      // Normalize direction vector
      final normalizedDx = dx / distance;
      final normalizedDy = dy / distance;

      // Perpendicular vector for circling motion (rotate 90 degrees)
      final perpDx = -normalizedDy;
      final perpDy = normalizedDx;

      double radialSpeed = 0;

      // If too far or too close, adjust distance
      if (distance > idealDistance * 1.2) {
        radialSpeed = 1.0; // Move closer
      } else if (distance < idealDistance * 0.8) {
        radialSpeed = -1.0; // Move away
      }

      // Calculate intended movement direction
      final intendedDx = perpDx * 1.2 + normalizedDx * radialSpeed;
      final intendedDy = perpDy * 1.2 + normalizedDy * radialSpeed;

      // Normalize the intended direction
      final intendedMag = sqrt(
        intendedDx * intendedDx + intendedDy * intendedDy,
      );
      final normalizedIntendedDx = intendedDx / intendedMag;
      final normalizedIntendedDy = intendedDy / intendedMag;

      // Check if there's an obstacle in the path
      final obstacleInPath = _checkObstacleInPath(
        enemy.centerX,
        enemy.centerY,
        normalizedIntendedDx,
        normalizedIntendedDy,
        enemy.width,
      );

      if (obstacleInPath) {
        // Find alternative direction for circling
        final alternativePath = _findCirclingAlternative(
          enemy.centerX,
          enemy.centerY,
          normalizedIntendedDx,
          normalizedIntendedDy,
          enemy.width,
        );

        // Apply impulse in alternative direction with original magnitude
        enemy.applyImpulse(
          alternativePath.dx * intendedMag,
          alternativePath.dy * intendedMag,
        );
      } else {
        // No obstacle, apply original impulse
        enemy.applyImpulse(intendedDx, intendedDy);
      }
    }
  }

  // Enemy AI: Move erratically with obstacle avoidance
  static void _applyErraticAI(Body enemy) {
    // Change direction randomly every few frames
    if (Game.random.nextInt(60) < 3) {
      // ~5% chance per frame
      bool validDirection = false;
      int attempts = 0;
      final maxAttempts = 8; // Limit attempts to find clear path

      while (!validDirection && attempts < maxAttempts) {
        final randomAngle = Game.random.nextDouble() * 2 * pi;
        final randomDx = cos(randomAngle);
        final randomDy = sin(randomAngle);
        final randomSpeed = 0.5 + Game.random.nextDouble() * 2.0;

        // Check if direction has obstacle
        validDirection =
            !_checkObstacleInPath(
              enemy.centerX,
              enemy.centerY,
              randomDx,
              randomDy,
              enemy.width,
            );

        if (validDirection) {
          // Apply impulse in clear direction
          enemy.applyImpulse(randomDx * randomSpeed, randomDy * randomSpeed);
          break;
        }

        attempts++;
      }

      // If couldn't find clear path, use avoidance algorithm
      if (!validDirection) {
        final randomAngle = Game.random.nextDouble() * 2 * pi;
        final randomDx = cos(randomAngle);
        final randomDy = sin(randomAngle);
        final randomSpeed = 0.5 + Game.random.nextDouble() * 2.0;

        final alternativePath = _findCirclingAlternative(
          enemy.centerX,
          enemy.centerY,
          randomDx,
          randomDy,
          enemy.width,
        );

        enemy.applyImpulse(
          alternativePath.dx * randomSpeed,
          alternativePath.dy * randomSpeed,
        );
      }
    }

    // Occasionally dash towards player
    if (Game.random.nextInt(180) < 2) {
      // ~1% chance per frame
      _applyChaseAI(enemy, 3.0); // Dash with higher speed
    }
  }

  // Enemy AI: Chase player directly with obstacle avoidance
  static void _applyChaseAI(Body enemy, double speed) {
    // Chase player if velocity is low
    if (enemy.xVelocity.abs() < 1.0 && enemy.yVelocity.abs() < 1.0) {
      final dx = Player.body.centerX - enemy.centerX;
      final dy = Player.body.centerY - enemy.centerY;
      final distance = sqrt(dx * dx + dy * dy);

      if (distance > 0) {
        // Normalize direction vector
        final normalizedDx = dx / distance;
        final normalizedDy = dy / distance;

        // Check if there's an obstacle in the path
        final obstacleInPath = _checkObstacleInPath(
          enemy.centerX,
          enemy.centerY,
          normalizedDx,
          normalizedDy,
          enemy.width,
        );

        if (obstacleInPath) {
          // Find alternative path
          final alternativePath = _findAlternativePath(
            enemy.centerX,
            enemy.centerY,
            Player.body.centerX,
            Player.body.centerY,
            enemy.width,
          );

          // Apply impulse in alternative direction
          enemy.applyImpulse(
            alternativePath.dx * speed,
            alternativePath.dy * speed,
          );
        } else {
          // No obstacle in path, move directly toward player
          enemy.applyImpulse(normalizedDx * speed, normalizedDy * speed);
        }
      }
    }
  }

  static void update() {
    for (int i = 0; i < Level.enemies.length; i++) {
      // Get current enemy
      Enemy enemy = Level.enemies[i];

      if (!enemy.dead) {
        // Apply friction
        enemy.body.xVelocity *= Player.friction;
        enemy.body.yVelocity *= Player.friction;

        // Update position
        enemy.body.update();

        // Handle wall collisions
        _handleEnemyWallCollisions(enemy.body);

        // Apply AI behavior
        _applyEnemyAI(enemy.body, i);

        // Check for collisions with other enemies
        Engine.handleEnemyToEnemyCollisions(i);

        // Check for collision with player
        if (enemy.body.collidesWith(Player.body)) {
          Engine.handleEnemyPlayerCollision(enemy.body);
        }

        // Try to shoot at player if cooldown allows
        _handleEnemyShooting(enemy, i);
      }
    }
  }

  static bool _isNearPlayer(double x, double y, double minDistance) {
    if (!Player.body.x.isNaN) {
      // Make sure player is initialized
      double playerCenterX = Game.gameWidth / 2;
      double playerCenterY = Game.gameHeight / 2;
      double distance = sqrt(
        pow(x - playerCenterX, 2) + pow(y - playerCenterY, 2),
      );
      return distance < minDistance;
    }
    return false;
  }

  // Check if there's an obstacle in the path
  static bool _checkObstacleInPath(
    double startX,
    double startY,
    double normalizedDx,
    double normalizedDy,
    double entitySize,
  ) {
    // Look ahead distance based on entity size
    final lookAheadDistance = entitySize * 3.0;
    final endX = startX + normalizedDx * lookAheadDistance;
    final endY = startY + normalizedDy * lookAheadDistance;

    // Simple ray casting to detect obstacle collision
    for (Obstacle obstacle in Level.obstacles) {
      // Use a simplified line-rectangle intersection test
      if (_lineIntersectsRect(
        startX,
        startY,
        endX,
        endY,
        obstacle.body.left,
        obstacle.body.top,
        obstacle.body.right,
        obstacle.body.bottom,
      )) {
        return true;
      }
    }

    return false;
  }

  // Check if a line intersects with a rectangle
  static bool _lineIntersectsRect(
    double x1,
    double y1,
    double x2,
    double y2,
    double rectLeft,
    double rectTop,
    double rectRight,
    double rectBottom,
  ) {
    // Check if line intersects any of the rectangle's edges
    return (_lineIntersectsLine(
          x1,
          y1,
          x2,
          y2,
          rectLeft,
          rectTop,
          rectRight,
          rectTop,
        ) ||
        _lineIntersectsLine(
          x1,
          y1,
          x2,
          y2,
          rectRight,
          rectTop,
          rectRight,
          rectBottom,
        ) ||
        _lineIntersectsLine(
          x1,
          y1,
          x2,
          y2,
          rectRight,
          rectBottom,
          rectLeft,
          rectBottom,
        ) ||
        _lineIntersectsLine(
          x1,
          y1,
          x2,
          y2,
          rectLeft,
          rectBottom,
          rectLeft,
          rectTop,
        ) ||
        // Also check if start or end point is inside the rectangle
        (x1 >= rectLeft &&
            x1 <= rectRight &&
            y1 >= rectTop &&
            y1 <= rectBottom) ||
        (x2 >= rectLeft &&
            x2 <= rectRight &&
            y2 >= rectTop &&
            y2 <= rectBottom));
  }

  // Check if two line segments intersect
  static bool _lineIntersectsLine(
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
    double x4,
    double y4,
  ) {
    // Calculate denominators
    final denom = (y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1);

    // If denominator is zero, lines are parallel
    if (denom.abs() < 0.0001) return false;

    final ua = ((x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3)) / denom;
    final ub = ((x2 - x1) * (y1 - y3) - (y2 - y1) * (x1 - x3)) / denom;

    // Return true if the intersection is within both line segments
    return ua >= 0 && ua <= 1 && ub >= 0 && ub <= 1;
  }

  // Find alternative path for chase AI when obstacle is detected
  static PathVector _findAlternativePath(
    double enemyX,
    double enemyY,
    double targetX,
    double targetY,
    double entitySize,
  ) {
    // Try several possible angles to find path without obstacles
    List<double> angles = [
      // Try 45 degrees left and right of current direction
      pi / 4, -pi / 4,
      // Try 90 degrees left and right
      pi / 2, -pi / 2,
      // Try more angles if needed
      3 * pi / 4, -3 * pi / 4,
      // In worst case, try going opposite direction
      pi,
    ];

    // Get direction to target
    final dx = targetX - enemyX;
    final dy = targetY - enemyY;
    final originalAngle = atan2(dy, dx);

    // Try each alternative angle
    for (double angleOffset in angles) {
      final testAngle = originalAngle + angleOffset;
      final testDx = cos(testAngle);
      final testDy = sin(testAngle);

      // Check if this direction is clear
      if (!_checkObstacleInPath(enemyX, enemyY, testDx, testDy, entitySize)) {
        return PathVector(testDx, testDy);
      }
    }

    // If all directions have obstacles, return the original direction
    // but with a slight randomization to prevent getting stuck
    final randomAngle =
        originalAngle + (Game.random.nextDouble() - 0.5) * pi / 2;
    return PathVector(cos(randomAngle), sin(randomAngle));
  }

  // Find alternative circling direction when obstacle is detected
  static PathVector _findCirclingAlternative(
    double enemyX,
    double enemyY,
    double intendedDx,
    double intendedDy,
    double entitySize,
  ) {
    // Try rotating the vector by various angles
    List<double> angles = [
      pi / 6,
      -pi / 6,
      pi / 3,
      -pi / 3,
      pi / 2,
      -pi / 2,
      2 * pi / 3,
      -2 * pi / 3,
      5 * pi / 6,
      -5 * pi / 6,
    ];

    // Get original angle
    final originalAngle = atan2(intendedDy, intendedDx);

    // Try each alternative angle
    for (double angleOffset in angles) {
      final testAngle = originalAngle + angleOffset;
      final testDx = cos(testAngle);
      final testDy = sin(testAngle);

      // Check if this direction is clear
      if (!_checkObstacleInPath(enemyX, enemyY, testDx, testDy, entitySize)) {
        return PathVector(testDx, testDy);
      }
    }

    // If all directions have obstacles, return the opposite direction as last resort
    return PathVector(-intendedDx, -intendedDy);
  }

  static void spawn() {
    if (remaining > count - max) {
      for (Enemy enemy in Level.enemies) {
        if (enemy.dead) {
          double maxWidth = Game.gameWidth - Mob.size.width;
          double maxHeight = Game.gameHeight - Mob.size.height;
          double enemyX, enemyY;

          final hue = Game.random.nextInt(360);
          final color =
              HSVColor.fromAHSV(1.0, hue.toDouble(), 0.7, 0.9).toColor();

          do {
            enemyX = Game.random.nextDouble() * maxWidth;
            enemyY = Game.random.nextDouble() * maxHeight;
          } while (_isNearPlayer(enemyX, enemyY, 300));

          enemy.body.x = enemyX;
          enemy.body.y = enemyY;
          enemy.body.xVelocity = Game.random.nextDouble() * 2 - 1;
          enemy.body.yVelocity = Game.random.nextDouble() * 2 - 1;
          enemy.body.width = Mob.size.width * 0.8;
          enemy.body.height = Mob.size.height * 0.8;
          enemy.body.color = color;
          enemy.body.mass = Mob.mass;

          enemy.dead = false;
          enemy.hp = hp;

          return;
        }
      }
    }
  }

  static Widget build(Enemy enemy, Camera camera) {
    if (!enemy.dead) {
      return Positioned(
        left: enemy.body.x - camera.x,
        top: enemy.body.y - camera.y,
        child: Container(
          width: enemy.body.width,
          height: enemy.body.height,
          decoration: BoxDecoration(
            color: enemy.body.color,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Enemy',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                Text(
                  enemy.hp.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}

class Enemy {
  Body body = Body(
    x: 0,
    y: 0,
    width: Mob.size.width,
    height: Mob.size.width,
    color: Colors.pink,
  );
  int hp = 3;
  bool dead = false;
  bool canShoot = false;
  int cooldown = 2000;

  Enemy({required this.body});

  void hurt() {
    hp -= 1;

    var r = body.color.r / 4;
    var g = body.color.g / 4;
    var b = body.color.b / 4;

    body.color = Color.from(alpha: 1.0, red: r, green: g, blue: b);
    if (hp < 1 && !dead) {
      //Game.state.kills++;
      dead = true;
      Mob.spawn();
      Mob.remaining--;
    }
  }
}
