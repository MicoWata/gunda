import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gunda/src/ball.dart';
import 'package:gunda/src/body.dart';
import 'package:gunda/src/effect.dart';
import 'package:gunda/src/game.dart';
import 'package:gunda/src/mob.dart';

class Engine {
  static const double wallBounce = 0.7;
  static const double collisionBounce = 0.8;

  static void handleCollision() {
    //// Get collision information
    //final CollisionInfo collisionInfo =
    //    CollisionPhysics.calculateCollisionResponse(
    //      Game.state.player,
    //      Game.state.target,
    //    );
    //
    //// Don't apply collision if objects are moving away from each other
    //if (collisionInfo.velocityAlongNormal > 0) return;
    //
    //// Apply collision response
    //CollisionPhysics.applyCollisionImpulse(
    //  Game.state.player,
    //  Game.state.target,
    //  collisionInfo,
    //);
    //
    //// Create visual effects
    //Effect.collide(collisionInfo);
  }

  static void checkCollisions(Size screenSize) {
    final playerSpeed = sqrt(
      Game.state.player.xVelocity * Game.state.player.xVelocity +
          Game.state.player.yVelocity * Game.state.player.yVelocity,
    );

    if (((Game.state.player.x <= 0 ||
                Game.state.player.x >=
                    screenSize.width - Game.state.player.width) &&
            Game.state.player.xVelocity.abs() > 5.0) ||
        ((Game.state.player.y <= 0 ||
                Game.state.player.y >=
                    screenSize.height - Game.state.player.height) &&
            Game.state.player.yVelocity.abs() > 5.0)) {
      // Reduce lives on high-speed impact with walls
      if (playerSpeed > 6.0 && !Game.state.isGameOver) {
        Game.state.lives = Game.state.lives - 1;

        // Check for game over
        if (Game.state.lives <= 0) {
          Game.state.isGameOver = true;
          Game.state.animationController.stop();
        }
      }
    }

    // Check for projectile collisions with enemies and player
    for (int i = Game.state.projectiles.length - 1; i >= 0; i--) {
      Projectile projectile = Game.state.projectiles[i];

      if (projectile.isPlayerProjectile) {
        // Player projectiles can hit enemies
        for (int j = Game.state.enemies.length - 1; j >= 0; j--) {
          Enemy enemy = Game.state.enemies[j];

          if (projectile.collidesWith(enemy.body)) {
            // Handle player projectile collision with enemy
            Ball.handleProjectileEnemyCollision(projectile, enemy.body, i, j);
            enemy.hurt();
            break; // Projectile is removed, move to next one
          }
        }
      } else {
        // Enemy projectiles can hit player
        if (projectile.collidesWith(Game.state.player)) {
          // Handle enemy projectile collision with player
          Ball.handleProjectilePlayerCollision(projectile, i);
          continue; // Projectile is removed, move to next one
        }
      }
    }
  }

  static void handleEnemyToEnemyCollisions(int enemyIndex) {
    final enemy = Game.state.enemies[enemyIndex];

    // Check for collisions with other enemies
    for (int j = enemyIndex + 1; j < Game.state.enemies.length; j++) {
      final otherEnemy = Game.state.enemies[j];

      if (enemy.body.collidesWith(otherEnemy.body)) {
        // Get collision info
        final CollisionInfo collisionInfo =
            CollisionPhysics.calculateCollisionResponse(
              enemy.body,
              otherEnemy.body,
            );

        // Apply collision response if they're moving toward each other
        if (collisionInfo.velocityAlongNormal < 0) {
          CollisionPhysics.applyCollisionImpulse(
            enemy.body,
            otherEnemy.body,
            collisionInfo,
          );

          // Visual effects for collision
          Effect.impact(
            collisionInfo.collisionX,
            collisionInfo.collisionY,
            Colors.grey,
            collisionInfo.impactEnergy * 0.5,
            Game.state,
          );
        }
      }
    }
  }

  // Handle collision between enemy and player
  static void handleEnemyPlayerCollision(Body enemy) {
    // Get collision info
    final CollisionInfo collisionInfo =
        CollisionPhysics.calculateCollisionResponse(Game.state.player, enemy);

    // Apply collision response if they're moving toward each other
    if (collisionInfo.velocityAlongNormal < 0) {
      CollisionPhysics.applyCollisionImpulse(
        Game.state.player,
        enemy,
        collisionInfo,
      );

      // Visual effects for collision
      Effect.impact(
        collisionInfo.collisionX,
        collisionInfo.collisionY,
        Colors.orange,
        collisionInfo.impactEnergy,
        Game.state,
      );
    }
  }

  static void handleProjectileCollision(Projectile projectile, int index) {
    // Calculate collision response vector
    //final collisionNormalX = projectile.x - Game.state.target.centerX;
    //final collisionNormalY = projectile.y - Game.state.target.centerY;
    //
    //// Normalize the collision vector
    //final magnitude = sqrt(
    //  collisionNormalX * collisionNormalX + collisionNormalY * collisionNormalY,
    //);
    //
    //final normalizedX = collisionNormalX / magnitude;
    //final normalizedY = collisionNormalY / magnitude;
    //
    //// Calculate impact force based on projectile energy
    //final impactForce = projectile.energy * 0.05;
    //
    //// Apply force to target with conservation of momentum
    //final impulseX = normalizedX * impactForce;
    //final impulseY = normalizedY * impactForce;
    //
    //// Apply impulse to target
    //Game.state.target.applyImpulse(impulseX, impulseY);
    //
    //// Create impact particles
    //Effect.impact(
    //  projectile.x,
    //  projectile.y,
    //  projectile.color,
    //  impactForce / 5,
    //  Game.state,
    //);
    //
    //// Activate slow motion for dramatic effect on powerful hits
    //if (impactForce > 8) {
    //  Game.effect.showSlowMotion = true;
    //  Game.effect.slowMotionTimer = Game.effect.maxSlowMotionTime;
    //}
    //
    //// Increment score based on impact force
    //Game.state.score += (Mob.value * impactForce / 3).ceil();
    //
    //// Remove the projectile
    ////setState(() {
    //Game.state.projectiles.removeAt(index);
    //});
  }

  static void updatePlayerPhysics() {
    // Update player position
    Game.state.player.update();

    // Keep player within bounds and handle wall collisions
    if (Game.state.player.x <= 0) {
      Game.state.player.x = 0;
      Game.state.player.xVelocity = -Game.state.player.xVelocity * wallBounce;

      // Create wall impact particles
      if (Game.state.player.xVelocity.abs() > 2.0) {
        Effect.impact(
          Game.state.player.x,
          Game.state.player.centerY,
          Colors.blue,
          Game.state.player.xVelocity.abs() / 5,
          Game.state,
        );
      }
    } else if (Game.state.player.x >=
        Game.gameWidth - Game.state.player.width) {
      Game.state.player.x = Game.gameWidth - Game.state.player.width;
      Game.state.player.xVelocity = -Game.state.player.xVelocity * wallBounce;

      // Create wall impact particles
      if (Game.state.player.xVelocity.abs() > 2.0) {
        Effect.impact(
          Game.state.player.right,
          Game.state.player.centerY,
          Colors.blue,
          Game.state.player.xVelocity.abs() / 5,
          Game.state,
        );
      }
    }

    if (Game.state.player.y <= 0) {
      Game.state.player.y = 0;
      Game.state.player.yVelocity = -Game.state.player.yVelocity * wallBounce;

      // Create wall impact particles
      if (Game.state.player.yVelocity.abs() > 2.0) {
        Effect.impact(
          Game.state.player.centerX,
          Game.state.player.y,
          Colors.blue,
          Game.state.player.yVelocity.abs() / 5,
          Game.state,
        );
      }
    } else if (Game.state.player.y >=
        Game.gameHeight - Game.state.player.height) {
      Game.state.player.y = Game.gameHeight - Game.state.player.height;
      Game.state.player.yVelocity = -Game.state.player.yVelocity * wallBounce;

      // Create wall impact particles
      if (Game.state.player.yVelocity.abs() > 2.0) {
        Effect.impact(
          Game.state.player.centerX,
          Game.state.player.bottom,
          Colors.blue,
          Game.state.player.yVelocity.abs() / 5,
          Game.state,
        );
      }
    }

    // Camera follow moved to _updatePosition method for better control
  }
}

class CollisionInfo {
  final double normalizedX;
  final double normalizedY;
  final double velocityAlongNormal;
  final double impulseX;
  final double impulseY;
  final double impactEnergy;
  final double collisionX;
  final double collisionY;

  CollisionInfo({
    required this.normalizedX,
    required this.normalizedY,
    required this.velocityAlongNormal,
    required this.impulseX,
    required this.impulseY,
    required this.impactEnergy,
    required this.collisionX,
    required this.collisionY,
  });
}

/// Helper class for collision physics calculations
class CollisionPhysics {
  /// Calculate collision response values between two GameRectangle objects
  static CollisionInfo calculateCollisionResponse(Body first, Body second) {
    // Calculate collision response vector
    final collisionNormalX = first.centerX - second.centerX;
    final collisionNormalY = first.centerY - second.centerY;

    // Normalize the collision vector
    final magnitude = sqrt(
      collisionNormalX * collisionNormalX + collisionNormalY * collisionNormalY,
    );

    final normalizedX = collisionNormalX / magnitude;
    final normalizedY = collisionNormalY / magnitude;

    // Calculate relative velocity
    final relativeVelocityX = first.xVelocity - second.xVelocity;
    final relativeVelocityY = first.yVelocity - second.yVelocity;

    // Calculate velocity along the normal
    final velocityAlongNormal =
        relativeVelocityX * normalizedX + relativeVelocityY * normalizedY;

    // Calculate collision impulse scalar
    final restitution = Engine.collisionBounce;
    final impulseMagnitude =
        -(1 + restitution) *
        velocityAlongNormal /
        (1 / first.mass + 1 / second.mass);

    // Calculate impulse components
    final impulseX = normalizedX * impulseMagnitude;
    final impulseY = normalizedY * impulseMagnitude;

    // Calculate impact energy
    final impactEnergy =
        (velocityAlongNormal.abs()) * (first.mass + second.mass) / 20;

    // Calculate collision point
    final collisionX = (first.centerX + second.centerX) / 2;
    final collisionY = (first.centerY + second.centerY) / 2;

    return CollisionInfo(
      normalizedX: normalizedX,
      normalizedY: normalizedY,
      velocityAlongNormal: velocityAlongNormal,
      impulseX: impulseX,
      impulseY: impulseY,
      impactEnergy: impactEnergy,
      collisionX: collisionX,
      collisionY: collisionY,
    );
  }

  /// Apply the collision impulse to both objects
  static void applyCollisionImpulse(
    Body first,
    Body second,
    CollisionInfo info,
  ) {
    // Apply impulse to both objects with appropriate mass scaling
    first.applyImpulse(info.impulseX, info.impulseY);
    second.applyImpulse(-info.impulseX, -info.impulseY);
  }
}
