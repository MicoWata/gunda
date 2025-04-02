import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gunda/src/ball.dart';
import 'package:gunda/src/camera.dart';
import 'package:gunda/src/effect.dart';
import 'package:gunda/src/game.dart';
import 'package:gunda/src/level.dart';
import 'package:gunda/src/player.dart';
import 'package:gunda/src/state.dart';

class Weapon {
  static const double minPower = 8.0;
  static const double maxPower = 30.0;
  static const double powerIncreaseRate = 0.3;

  // Cooldown for shooting
  static bool canShoot = true;
  static final cooldown = 300; // milliseconds

  // Power meter for shooting
  static double power = Weapon.minPower;
  static bool isChargingShot = false;

  static Offset _getLimitedLineEndPoint(
    Offset start,
    Offset end,
    double maxLength,
  ) {
    double dx = end.dx - start.dx;
    double dy = end.dy - start.dy;
    double distance = sqrt(dx * dx + dy * dy);

    if (distance <= maxLength) {
      return end;
    } else {
      double ratio = maxLength / distance;
      return Offset(start.dx + dx * ratio, start.dy + dy * ratio);
    }
  }

  static void startChargingShot() {
    if (!canShoot ||
        isChargingShot ||
        Game.state.projectiles.length >= Ball.maxProjectiles) {
      return;
    }

    //setState(() {
    isChargingShot = true;
    power = minPower;
    //});
  }

  static void releaseShot(Offset mouse) {
    if (!isChargingShot) return;

    // Calculate direction from player to mouse
    final playerCenterX = Game.state.player.centerX;
    final playerCenterY = Game.state.player.centerY;

    // Calculate vector from player to world mouse position
    final dx = mouse.dx - playerCenterX;
    final dy = mouse.dy - playerCenterY;

    // Normalize the vector
    final distance = sqrt(dx * dx + dy * dy);

    if (distance > 0) {
      final normalizedDx = dx / distance;
      final normalizedDy = dy / distance;

      // Create projectile color based on power
      final powerPercentage = (power - minPower) / (maxPower - minPower);

      final projectileColor =
          ColorTween(
            begin: Colors.yellow,
            end: Colors.red,
          ).lerp(powerPercentage) ??
          Colors.orange;

      // Create a new projectile with velocity in mouse direction and variable power
      final projectile = Projectile(
        x: playerCenterX,
        y: playerCenterY,
        xVelocity: normalizedDx * power,
        yVelocity: normalizedDy * power,
        radius: Ball.projectileRadius,
        color: projectileColor,
        mass: Ball.mass,
      );

      // Apply recoil to player (conservation of momentum)
      final recoilForce = power * Ball.mass / Player.playerMass;

      Game.state.player.applyImpulse(
        -normalizedDx * recoilForce * 2,
        -normalizedDy * recoilForce * 2,
      );

      //setState(() {
      Game.state.projectiles.add(projectile);
      isChargingShot = false;

      // Create particle effect at launch position
      Effect.impact(
        playerCenterX,
        playerCenterY,
        Colors.yellow,
        powerPercentage * 1.5,
        Game.state,
      );
      //});

      // Set cooldown
      canShoot = false;
      Future.delayed(Duration(milliseconds: cooldown), () {
        //if (mounted) {
        //setState(() {
        canShoot = true;
        //});
        //}
      });
    }
  }

  static void updateChargingPower() {
    if (!isChargingShot) return;

    //setState(() {
    power += powerIncreaseRate;
    if (power > maxPower) {
      power = maxPower;
    }
    //});
  }

  static Widget build(
    double screenWidth,
    double screenHeight,
    Offset mousePosition,
    GameState gameState,
    Camera camera,
  ) {
    if (!gameState.isGameOver) {
      return CustomPaint(
        size: Size(screenWidth, screenHeight),
        painter: LinePainter(
          start: Offset(
            gameState.player.centerX - camera.x,
            gameState.player.centerY - camera.y,
          ),
          end: _getLimitedLineEndPoint(
            Offset(
              gameState.player.centerX - camera.x,
              gameState.player.centerY - camera.y,
            ),
            mousePosition,
            100.0, // Longer aiming line for larger map
          ),
          powerLevel: isChargingShot ? power : minPower,
          cameraX: camera.x,
          cameraY: camera.y,
        ),
      );
    } else {
      return Container();
    }
  }
}
