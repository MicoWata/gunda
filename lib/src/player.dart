import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gunda/src/body.dart';
import 'package:gunda/src/camera.dart';
import 'package:gunda/src/game.dart';
import 'package:gunda/src/level.dart';
import 'package:gunda/src/mob.dart';
import 'package:gunda/src/weapon.dart';

class Player {
  static const double width = 80;
  static const double height = 100;

  static int maxHearts = 3;
  static int lives = 3;
  static int score = 0;
  static Body body = Body(x: 0, y: 0, width: 0, height: 0, color: Colors.red);

  static const double acceleration = 0.8;
  static const double maxSpeed = 64.0;
  static const double friction = 0.9;
  static const double minMovementThreshold = 0.1;

  static final Set<LogicalKeyboardKey> _pressedKeys = {};

  static Offset mousePosition = Offset.zero;
  static Offset worldMousePosition = Offset.zero;

  static const double playerMass = 10.0;

  static void updateMousePosition(PointerEvent event) {
    //setState(() {
    Player.mousePosition = event.position;

    // Convert screen coordinates to world coordinates by adding camera position
    Player.worldMousePosition = Offset(
      Game.camera.x + event.position.dx,
      Game.camera.y + event.position.dy,
    );
    //});
  }

  static void kill() {
    for (Enemy mob in Level.enemies) {
      if (mob.hp > 0) {
        mob.hurt();
      }
    }
  }

  // Aimpoint dash
  // static void dash() {
  //   Offset mouse = worldMousePosition;
  //   double power = 50;

  //   final recoilForce = power * 24 / Player.playerMass;

  //   // Calculate direction from player to mouse
  //   final playerCenterX = Player.body.centerX;
  //   final playerCenterY = Player.body.centerY;

  //   // Calculate vector from player to world mouse position
  //   final dx = mouse.dx - playerCenterX;
  //   final dy = mouse.dy - playerCenterY;

  //   // Normalize the vector
  //   final distance = sqrt(dx * dx + dy * dy);
  //   final normalizedDx = dx / distance;
  //   final normalizedDy = dy / distance;

  //   Player.body.applyImpulse(
  //     normalizedDx * recoilForce * 2,
  //     normalizedDy * recoilForce * 2,
  //   );
  // }

  // Directional dash
  static void dash() {
    double power = 50;
    final recoilForce = power * 24 / Player.playerMass;

    // Get current velocity
    final vx = Player.body.xVelocity;
    final vy = Player.body.yVelocity;

    final speed = sqrt(vx * vx + vy * vy);

    // Don't dash if the player isn't moving
    if (speed == 0) return;

    // Normalize the velocity vector
    final normalizedDx = vx / speed;
    final normalizedDy = vy / speed;

    // Apply dash impulse in the direction of movement
    Player.body.applyImpulse(
      normalizedDx * recoilForce * 2,
      normalizedDy * recoilForce * 2,
    );
  }

  static void enter() {
    if (Game.over) {
      if (Level.remaining > 0) {
        Game.reset();
        Game.animationController.repeat();
      } else if (Game.level < Level.zones.length - 1) {
        Game.nextLevel();
        Game.animationController.repeat();
      } else {
        Game.reset();
        Game.animationController.repeat();
      }
    }
  }

  static void click() {
    attack();
  }

  static void release() {
    if (Weapon.isChargingShot) {
      Weapon.releaseShot(worldMousePosition);
    }
  }

  static void attack() {
    if (Weapon.kind == Weapons.pistol ||
        Weapon.kind == Weapons.shotgun ||
        Weapon.kind == Weapons.bazooka) {
      shoot();
    } else {
      hit();
    }
  }

  static void shoot() {
    if (!Game.over && !Game.paused) {
      if (Weapon.kind == Weapons.pistol && !Weapon.isChargingShot) {
        Weapon.startChargingShot();
      } else if (Weapon.kind == Weapons.shotgun) {
        Weapon.spreadShot(worldMousePosition);
      } else if (Weapon.kind == Weapons.bazooka) {
        Weapon.explosiveShot(worldMousePosition);
      }
    }
  }

  static void hit() {
    if (!Game.over && !Game.paused) {
      Weapon.slice();
    }
  }

  static void changeWeapon() {
    switch (Weapon.kind) {
      case Weapons.sword:
        Weapon.kind = Weapons.pistol;
      case Weapons.pistol:
        Weapon.kind = Weapons.shotgun;
      case Weapons.shotgun:
        Weapon.kind = Weapons.bazooka;
      case Weapons.bazooka:
        Weapon.kind = Weapons.sword;
    }
  }

  static void handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      _pressedKeys.add(event.logicalKey);

      if (event.logicalKey == LogicalKeyboardKey.space) {
        dash();
      }

      if (event.logicalKey == LogicalKeyboardKey.keyE) {
        changeWeapon();
      }
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        Game.paused = !Game.paused;
      }

      if (event.logicalKey == LogicalKeyboardKey.keyK) {
        kill();
      }
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        enter();
      }
      //if (event.logicalKey == LogicalKeyboardKey.space) {
      //  attack();
      //}
    } else if (event is KeyUpEvent) {
      //if (event.logicalKey == LogicalKeyboardKey.space &&
      //    Weapon.isChargingShot) {
      //  Weapon.releaseShot(worldMousePosition);
      //}

      _pressedKeys.remove(event.logicalKey);
    }
  }

  static void updatePlayerMovement() {
    // Apply acceleration based on pressed keys
    if (_pressedKeys.contains(LogicalKeyboardKey.keyW)) {
      Player.body.yVelocity -= acceleration;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.keyS)) {
      Player.body.yVelocity += acceleration;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.keyA)) {
      Player.body.xVelocity -= acceleration;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.keyD)) {
      Player.body.xVelocity += acceleration;
    }

    // Apply friction to player
    Player.body.xVelocity *= friction;
    Player.body.yVelocity *= friction;

    // Limit player speed
    final currentSpeed = sqrt(
      Player.body.xVelocity * Player.body.xVelocity +
          Player.body.yVelocity * Player.body.yVelocity,
    );

    if (currentSpeed > maxSpeed) {
      final ratio = maxSpeed / currentSpeed;
      Player.body.xVelocity *= ratio;
      Player.body.yVelocity *= ratio;
    }

    // Stop very small movements
    if (Player.body.xVelocity.abs() < minMovementThreshold) {
      Player.body.xVelocity = 0;
    }
    if (Player.body.yVelocity.abs() < minMovementThreshold) {
      Player.body.yVelocity = 0;
    }
  }

  static Widget build(Camera camera) {
    return Positioned(
      left: Player.body.x - camera.x,
      top: Player.body.y - camera.y,
      child: Container(
        width: Player.body.width,
        height: Player.body.height,
        decoration: BoxDecoration(
          color: Player.body.color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50),
              blurRadius: 5,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Hero",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              //Text(
              //  'v: (${Player.body.xVelocity.toStringAsFixed(1)}, ${Player.body.yVelocity.toStringAsFixed(1)})',
              //  style: const TextStyle(color: Colors.white, fontSize: 10),
              //),
              Text(
                Player.lives.toString(),
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
