import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gunda/src/camera.dart';
import 'package:gunda/src/game.dart';
import 'package:gunda/src/state.dart';
import 'package:gunda/src/weapon.dart';

class Player {
  static const double width = 80;
  static const double height = 100;

  static int maxHearts = 3;
  static int lives = 3;
  static int score = 0;

  static const double acceleration = 0.8;
  static const double maxSpeed = 32.0;
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

  static void dash() {
    Offset mouse = worldMousePosition;
    double power = 50;

    final recoilForce = power * 24 / Player.playerMass;

    // Calculate direction from player to mouse
    final playerCenterX = Game.state.player.centerX;
    final playerCenterY = Game.state.player.centerY;

    // Calculate vector from player to world mouse position
    final dx = mouse.dx - playerCenterX;
    final dy = mouse.dy - playerCenterY;

    // Normalize the vector
    final distance = sqrt(dx * dx + dy * dy);
    final normalizedDx = dx / distance;
    final normalizedDy = dy / distance;

    Game.state.player.applyImpulse(
      -normalizedDx * recoilForce * 2,
      -normalizedDy * recoilForce * 2,
    );
  }

  static void handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      _pressedKeys.add(event.logicalKey);

      if (event.logicalKey == LogicalKeyboardKey.keyE) {
        dash();
      }
      // Start charging shot when space bar is pressed
      if (event.logicalKey == LogicalKeyboardKey.space) {
        if (!Game.state.isGameOver && !Weapon.isChargingShot) {
          Weapon.startChargingShot();
        } else if (Game.state.isGameOver) {
          Game.state.resetGame();
          Game.state.animationController.repeat();
        }
      }
    } else if (event is KeyUpEvent) {
      // Release shot when space bar is released
      if (event.logicalKey == LogicalKeyboardKey.space &&
          Weapon.isChargingShot) {
        Weapon.releaseShot(worldMousePosition);
      }

      _pressedKeys.remove(event.logicalKey);
    }
  }

  static void updatePlayerMovement() {
    // Apply acceleration based on pressed keys
    if (_pressedKeys.contains(LogicalKeyboardKey.keyW)) {
      Game.state.player.yVelocity -= acceleration;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.keyS)) {
      Game.state.player.yVelocity += acceleration;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.keyA)) {
      Game.state.player.xVelocity -= acceleration;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.keyD)) {
      Game.state.player.xVelocity += acceleration;
    }

    // Apply friction to player
    Game.state.player.xVelocity *= friction;
    Game.state.player.yVelocity *= friction;

    // Limit player speed
    final currentSpeed = sqrt(
      Game.state.player.xVelocity * Game.state.player.xVelocity +
          Game.state.player.yVelocity * Game.state.player.yVelocity,
    );

    if (currentSpeed > maxSpeed) {
      final ratio = maxSpeed / currentSpeed;
      Game.state.player.xVelocity *= ratio;
      Game.state.player.yVelocity *= ratio;
    }

    // Stop very small movements
    if (Game.state.player.xVelocity.abs() < minMovementThreshold) {
      Game.state.player.xVelocity = 0;
    }
    if (Game.state.player.yVelocity.abs() < minMovementThreshold) {
      Game.state.player.yVelocity = 0;
    }
  }

  static Widget build(GameState gameState, Camera camera) {
    return Positioned(
      left: gameState.player.x - camera.x,
      top: gameState.player.y - camera.y,
      child: Container(
        width: gameState.player.width,
        height: gameState.player.height,
        decoration: BoxDecoration(
          color: gameState.player.color,
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
                'Use arrow keys',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              //Text(
              //  'v: (${gameState.player.xVelocity.toStringAsFixed(1)}, ${gameState.player.yVelocity.toStringAsFixed(1)})',
              //  style: const TextStyle(color: Colors.white, fontSize: 10),
              //),
              const Text(
                'SPACE: Hold to charge, release to shoot',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
