import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gunda/src/ball.dart';
import 'package:gunda/src/body.dart';
import 'package:gunda/src/camera.dart';
import 'package:gunda/src/effect.dart';
import 'package:gunda/src/engine.dart';
import 'package:gunda/src/game.dart';
import 'package:gunda/src/level.dart';
import 'package:gunda/src/player.dart';
import 'package:gunda/src/weapon.dart';

class Mob {
  static double value = 1;
  static Size size = Size(100, 80);
  static double mass = 2.6;

  static void _handleEnemyShooting(Body enemy, int enemyIndex) {
    // Check if enemy can shoot (based on cooldown)
    if (Game.state.enemyCanShoot[enemyIndex]) {
      // Calculate distance to player
      final dx = Game.state.player.centerX - enemy.centerX;
      final dy = Game.state.player.centerY - enemy.centerY;
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
      Game.state.enemyShootCooldowns[enemyIndex] -=
          16; // Assume ~60fps, so ~16ms per frame

      // Reset cooldown if timer is done
      if (Game.state.enemyShootCooldowns[enemyIndex] <= 0) {
        Game.state.enemyCanShoot[enemyIndex] = true;
      }
    }
  }

  // Create and fire a projectile from enemy toward player
  static void _enemyShoot(Body enemy, int enemyIndex) {
    // Calculate direction from enemy to player
    final enemyCenterX = enemy.centerX;
    final enemyCenterY = enemy.centerY;

    // Vector from enemy to player
    final dx = Game.state.player.centerX - enemyCenterX;
    final dy = Game.state.player.centerY - enemyCenterY;

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
      final projectileColor = enemy.color.withValues(alpha: 0.8);

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
      final recoilForce = enemyPowerLevel * Ball.mass / enemy.mass;
      enemy.applyImpulse(
        -finalDx * recoilForce * 1.5, // Less recoil than player
        -finalDy * recoilForce * 1.5,
      );

      //setState(() {
      Game.state.projectiles.add(projectile);
      Game.state.enemyCanShoot[enemyIndex] = false;
      Game.state.enemyShootCooldowns[enemyIndex] =
          Game.state.defaultEnemyShootCooldown;

      // Create particle effect at launch position
      Effect.impact(
        enemyCenterX,
        enemyCenterY,
        projectileColor.withRed(
          ((projectileColor.r * 1.3).clamp(0, 255)).toInt(),
        ),
        (enemyPowerLevel / Weapon.maxPower) * 0.8, // Smaller effect than player
        Game.state,
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

  // Enemy AI: Circle around the player
  static void _applyCirclingAI(Body enemy) {
    final dx = Game.state.player.centerX - enemy.centerX;
    final dy = Game.state.player.centerY - enemy.centerY;
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

      // Apply circling impulse + distance adjustment
      enemy.applyImpulse(
        perpDx * 1.2 + normalizedDx * radialSpeed,
        perpDy * 1.2 + normalizedDy * radialSpeed,
      );
    }
  }

  // Enemy AI: Move erratically
  static void _applyErraticAI(Body enemy) {
    // Change direction randomly every few frames
    if (Game.random.nextInt(60) < 3) {
      // ~5% chance per frame
      final randomAngle = Game.random.nextDouble() * 2 * pi;
      final randomSpeed = 0.5 + Game.random.nextDouble() * 2.0;

      enemy.applyImpulse(
        cos(randomAngle) * randomSpeed,
        sin(randomAngle) * randomSpeed,
      );
    }

    // Occasionally dash towards player
    if (Game.random.nextInt(180) < 2) {
      // ~1% chance per frame
      _applyChaseAI(enemy, 3.0); // Dash with higher speed
    }
  }

  // Enemy AI: Chase player directly
  static void _applyChaseAI(Body enemy, double speed) {
    // Chase player if velocity is low
    if (enemy.xVelocity.abs() < 1.0 && enemy.yVelocity.abs() < 1.0) {
      final dx = Game.state.player.centerX - enemy.centerX;
      final dy = Game.state.player.centerY - enemy.centerY;
      final distance = sqrt(dx * dx + dy * dy);

      if (distance > 0) {
        // Normalize direction vector
        final normalizedDx = dx / distance;
        final normalizedDy = dy / distance;

        // Apply impulse towards player
        enemy.applyImpulse(normalizedDx * speed, normalizedDy * speed);
      }
    }
  }

  static void update() {
    for (int i = 0; i < Game.state.enemies.length; i++) {
      // Get current enemy
      Enemy enemy = Game.state.enemies[i];

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
      if (enemy.body.collidesWith(Game.state.player)) {
        Engine.handleEnemyPlayerCollision(enemy.body);
      }

      // Try to shoot at player if cooldown allows
      _handleEnemyShooting(enemy.body, i);
    }
  }

  static Widget build(Body enemy, Camera camera) {
    return Positioned(
      left: enemy.x - camera.x,
      top: enemy.y - camera.y,
      child: Container(
        width: enemy.width,
        height: enemy.height,
        decoration: BoxDecoration(
          color: enemy.color,
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
          child: Text(
            'Enemy',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
      ),
    );
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

  Enemy({required this.body});

  void hurt() {
    hp -= 1;
    body.color = Colors.black;

    if (hp < 1) {
      dead = true;
    }
  }
}
