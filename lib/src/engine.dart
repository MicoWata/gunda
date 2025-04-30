import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gunda/src/ball.dart';
import 'package:gunda/src/body.dart';
import 'package:gunda/src/effect.dart';
import 'package:gunda/src/game.dart';
import 'package:gunda/src/level.dart';
import 'package:gunda/src/mob.dart';
import 'package:gunda/src/obstacle.dart';
import 'package:gunda/src/player.dart';

class Engine {
  static const double wallBounce = 0.7;
  static const double collisionBounce = 0.8;

  static void checkCollisions(Size screenSize) {
    final playerSpeed = sqrt(
      Player.body.xVelocity * Player.body.xVelocity +
          Player.body.yVelocity * Player.body.yVelocity,
    );

    //if (((Player.body.x <= 0 ||
    //            Player.body.x >= screenSize.width - Player.body.width) &&
    //        Player.body.xVelocity.abs() > 5.0) ||
    //    ((Player.body.y <= 0 ||
    //            Player.body.y >= screenSize.height - Player.body.height) &&
    //        Player.body.yVelocity.abs() > 5.0)) {
    //  // Reduce lives on high-speed impact with walls
    //  //if (playerSpeed > 6.0 && !Game.over) {
    //  //  Player.lives = Player.lives - 1;
    //  //
    //  //  // Check for game over
    //  //  if (Player.lives < 1) {
    //  //    Game.over = true;
    //  //    //Game.animationController.stop();
    //  //  }
    //  //}
    //}

    // Check for projectile collisions with enemies and player
    for (int i = Level.projectiles.length - 1; i >= 0; i--) {
      Projectile projectile = Level.projectiles[i];

      if (projectile.isPlayerProjectile) {
        // Player projectiles can hit enemies
        for (int j = Level.enemies.length - 1; j >= 0; j--) {
          Enemy enemy = Level.enemies[j];

          if (!enemy.dead && projectile.collidesWith(enemy.body)) {
            // Handle player projectile collision with enemy
            Ball.handleProjectileEnemyCollision(projectile, enemy.body, i, j);
            enemy.hurt(1);
            break; // Projectile is removed, move to next one
          }
        }
      } else {
        // Enemy projectiles can hit player
        if (projectile.collidesWith(Player.body)) {
          // Handle enemy projectile collision with player
          Ball.handleProjectilePlayerCollision(projectile, i);
          continue; // Projectile is removed, move to next one
        }
      }
    }
  }

  static void handleEnemyToEnemyCollisions(int enemyIndex) {
    final enemy = Level.enemies[enemyIndex];

    // Check for collisions with other enemies
    for (int j = enemyIndex + 1; j < Level.enemies.length; j++) {
      final otherEnemy = Level.enemies[j];

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
          );
        }
      }
    }
  }

  // Handle collision between enemy and player
  static void handleEnemyPlayerCollision(Body enemy) {
    // Get collision info
    final CollisionInfo collisionInfo =
        CollisionPhysics.calculateCollisionResponse(Player.body, enemy);

    // Apply collision response if they're moving toward each other
    if (collisionInfo.velocityAlongNormal < 0) {
      CollisionPhysics.applyCollisionImpulse(Player.body, enemy, collisionInfo);

      // Visual effects for collision
      Effect.impact(
        collisionInfo.collisionX,
        collisionInfo.collisionY,
        Colors.orange,
        collisionInfo.impactEnergy,
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
    //Level.projectiles.removeAt(index);
    //});
  }

  /// Check for projectile collisions with obstacles
  static void handleProjectileObstacleCollisions() {
    for (int i = Level.projectiles.length - 1; i >= 0; i--) {
      Projectile projectile = Level.projectiles[i];

      for (Obstacle obstacle in Level.obstacles) {
        if (projectile.collidesWith(obstacle.body)) {
          // Calculate collision normal based on which side of the obstacle was hit
          double normalX = 0;
          double normalY = 0;

          // Determine the collision normal based on which side was hit
          // Calculate nearest point on projectile to obstacle
          final closestX = projectile.x.clamp(
            obstacle.body.left,
            obstacle.body.right,
          );
          final closestY = projectile.y.clamp(
            obstacle.body.top,
            obstacle.body.bottom,
          );

          // Calculate direction from closest point to projectile center
          final dirX = projectile.x - closestX;
          final dirY = projectile.y - closestY;

          // Normalize direction
          final magnitude = sqrt(dirX * dirX + dirY * dirY);
          if (magnitude > 0) {
            normalX = dirX / magnitude;
            normalY = dirY / magnitude;
          }

          // Reflect the velocity
          final dotProduct =
              projectile.xVelocity * normalX + projectile.yVelocity * normalY;
          projectile.xVelocity -= 2 * dotProduct * normalX * wallBounce;
          projectile.yVelocity -= 2 * dotProduct * normalY * wallBounce;

          // Move the projectile away from obstacle to prevent getting stuck
          projectile.x +=
              normalX * (projectile.radius + 1); // +1 for safety margin
          projectile.y += normalY * (projectile.radius + 1);

          // Increment bounce count
          projectile.bounceCount++;

          // Create impact particles
          final speed = sqrt(
            projectile.xVelocity * projectile.xVelocity +
                projectile.yVelocity * projectile.yVelocity,
          );

          Effect.impact(
            projectile.x,
            projectile.y,
            projectile.color,
            speed / 10,
          );

          break; // Only handle one collision per projectile per frame
        }
      }
    }
  }

  /// Check for collisions between player and obstacles
  static void handlePlayerObstacleCollisions() {
    Body player = Player.body;

    for (Obstacle obstacle in Level.obstacles) {
      if (player.collidesWith(obstacle.body)) {
        // Calculate collision normal based on which side of the obstacle was hit
        double normalX = 0;
        double normalY = 0;

        // Determine the collision normal based on which side was hit
        final dx1 = player.right - obstacle.body.left;
        final dx2 = obstacle.body.right - player.left;
        final dy1 = player.bottom - obstacle.body.top;
        final dy2 = obstacle.body.bottom - player.top;

        // Find the smallest penetration
        final List<double> penetrations = [dx1, dx2, dy1, dy2];
        final minPenetration = penetrations.reduce(min);

        if (minPenetration == dx1) {
          normalX = -1;
        } else if (minPenetration == dx2) {
          normalX = 1;
        } else if (minPenetration == dy1) {
          normalY = -1;
        } else if (minPenetration == dy2) {
          normalY = 1;
        }

        // Reflect the velocity
        if (normalX != 0) {
          player.xVelocity = -player.xVelocity * wallBounce;
        }
        if (normalY != 0) {
          player.yVelocity = -player.yVelocity * wallBounce;
        }

        // Move the player out of the obstacle
        if (normalX < 0) {
          player.x = obstacle.body.left - player.width;
        } else if (normalX > 0) {
          player.x = obstacle.body.right;
        }
        if (normalY < 0) {
          player.y = obstacle.body.top - player.height;
        } else if (normalY > 0) {
          player.y = obstacle.body.bottom;
        }

        // Create impact particles if the speed is significant
        final speed = sqrt(
          player.xVelocity * player.xVelocity +
              player.yVelocity * player.yVelocity,
        );

        if (speed > 2.0) {
          Effect.impact(player.centerX, player.centerY, Colors.blue, speed / 5);
        }
      }
    }
  }

  /// Check for enemy collisions with obstacles
  static void handleEnemyObstacleCollisions() {
    for (Enemy enemy in Level.enemies) {
      if (enemy.dead) continue;

      for (Obstacle obstacle in Level.obstacles) {
        if (enemy.body.collidesWith(obstacle.body)) {
          // Calculate collision normal based on which side of the obstacle was hit
          double normalX = 0;
          double normalY = 0;

          // Determine the collision normal based on which side was hit
          final dx1 = enemy.body.right - obstacle.body.left;
          final dx2 = obstacle.body.right - enemy.body.left;
          final dy1 = enemy.body.bottom - obstacle.body.top;
          final dy2 = obstacle.body.bottom - enemy.body.top;

          // Find the smallest penetration
          final List<double> penetrations = [dx1, dx2, dy1, dy2];
          final minPenetration = penetrations.reduce(min);

          if (minPenetration == dx1) {
            normalX = -1;
          } else if (minPenetration == dx2) {
            normalX = 1;
          } else if (minPenetration == dy1) {
            normalY = -1;
          } else if (minPenetration == dy2) {
            normalY = 1;
          }

          // Reflect the velocity
          if (normalX != 0) {
            enemy.body.xVelocity = -enemy.body.xVelocity * wallBounce;
          }
          if (normalY != 0) {
            enemy.body.yVelocity = -enemy.body.yVelocity * wallBounce;
          }

          // Move the enemy out of the obstacle
          if (normalX < 0) {
            enemy.body.x = obstacle.body.left - enemy.body.width;
          } else if (normalX > 0) {
            enemy.body.x = obstacle.body.right;
          }
          if (normalY < 0) {
            enemy.body.y = obstacle.body.top - enemy.body.height;
          } else if (normalY > 0) {
            enemy.body.y = obstacle.body.bottom;
          }

          break; // Only handle one collision per enemy per frame
        }
      }
    }
  }

  static void updatePlayerPhysics() {
    // Update player position
    Player.body.update();

    // Handle collision with obstacles
    handlePlayerObstacleCollisions();

    // Additionally check for projectile-obstacle collisions
    handleProjectileObstacleCollisions();

    // Check for enemy-obstacle collisions
    handleEnemyObstacleCollisions();

    // Keep player within bounds and handle wall collisions
    if (Player.body.x <= 0) {
      Player.body.x = 0;
      Player.body.xVelocity = -Player.body.xVelocity * wallBounce;

      // Create wall impact particles
      if (Player.body.xVelocity.abs() > 2.0) {
        Effect.impact(
          Player.body.x,
          Player.body.centerY,
          Colors.blue,
          Player.body.xVelocity.abs() / 5,
        );
      }
    } else if (Player.body.x >= Game.gameWidth - Player.body.width) {
      Player.body.x = Game.gameWidth - Player.body.width;
      Player.body.xVelocity = -Player.body.xVelocity * wallBounce;

      // Create wall impact particles
      if (Player.body.xVelocity.abs() > 2.0) {
        Effect.impact(
          Player.body.right,
          Player.body.centerY,
          Colors.blue,
          Player.body.xVelocity.abs() / 5,
        );
      }
    }

    if (Player.body.y <= 0) {
      Player.body.y = 0;
      Player.body.yVelocity = -Player.body.yVelocity * wallBounce;

      // Create wall impact particles
      if (Player.body.yVelocity.abs() > 2.0) {
        Effect.impact(
          Player.body.centerX,
          Player.body.y,
          Colors.blue,
          Player.body.yVelocity.abs() / 5,
        );
      }
    } else if (Player.body.y >= Game.gameHeight - Player.body.height) {
      Player.body.y = Game.gameHeight - Player.body.height;
      Player.body.yVelocity = -Player.body.yVelocity * wallBounce;

      // Create wall impact particles
      if (Player.body.yVelocity.abs() > 2.0) {
        Effect.impact(
          Player.body.centerX,
          Player.body.bottom,
          Colors.blue,
          Player.body.yVelocity.abs() / 5,
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

// Helper class for collision physics calculations
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

// Helper class for path finding
class PathVector {
  final double dx;
  final double dy;

  PathVector(this.dx, this.dy);
}
