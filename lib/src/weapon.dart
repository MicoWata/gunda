import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gunda/src/ball.dart';
import 'package:gunda/src/camera.dart';
import 'package:gunda/src/effect.dart';
import 'package:gunda/src/game.dart';
import 'package:gunda/src/level.dart';
import 'package:gunda/src/player.dart';

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
        Level.projectiles.length >= Ball.maxProjectiles) {
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
    final playerCenterX = Player.body.centerX;
    final playerCenterY = Player.body.centerY;

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

      Player.body.applyImpulse(
        -normalizedDx * recoilForce * 2,
        -normalizedDy * recoilForce * 2,
      );

      //setState(() {
      Level.projectiles.add(projectile);
      isChargingShot = false;

      // Create particle effect at launch position
      Effect.impact(
        playerCenterX,
        playerCenterY,
        Colors.yellow,
        powerPercentage * 1.5,
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
    Camera camera,
  ) {
    if (!Game.over) {
      return CustomPaint(
        size: Size(screenWidth, screenHeight),
        painter: LinePainter(
          start: Offset(
            Player.body.centerX - camera.x,
            Player.body.centerY - camera.y,
          ),
          end: _getLimitedLineEndPoint(
            Offset(
              Player.body.centerX - camera.x,
              Player.body.centerY - camera.y,
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

/// Custom painter to draw an aiming line with power meter
class LinePainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final double powerLevel;
  final double minPower;
  final double maxPower;
  final double cameraX;
  final double cameraY;

  LinePainter({
    required this.start,
    required this.end,
    required this.powerLevel,
    this.minPower = Weapon.minPower,
    this.maxPower = Weapon.maxPower,
    this.cameraX = 0,
    this.cameraY = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate line angle and length
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final lineLength = sqrt(dx * dx + dy * dy);
    final angle = atan2(dy, dx);

    // Calculate power percentage
    final powerPercentage = (powerLevel - minPower) / (maxPower - minPower);

    // Get power color (green to red gradient based on power)
    final powerColor =
        ColorTween(
          begin: Colors.green,
          end: Colors.red,
        ).lerp(powerPercentage) ??
        Colors.green;

    // Draw the trajectory prediction line
    final linePaint = Paint()..color = Colors.grey; //.withValues(alpha: 0.7)
    //..strokeWidth = 2
    //..strokeCap = StrokeCap.round;

    // Draw dashed trajectory line
    _drawDashedLine(canvas, start, end, linePaint);

    // Create power meter properties
    final rectHeight = 20.0;
    final maxRectWidth = lineLength;
    final currentRectWidth = maxRectWidth * powerPercentage;

    // Save canvas state before rotation
    canvas.save();

    // Translate to start point and rotate
    canvas.translate(start.dx, start.dy);
    canvas.rotate(angle);

    // Draw power meter background
    final rectBackgroundPaint =
        Paint()
          ..color =
              Colors
                  .grey //.withValues(alpha: 0.3)
          ..style = PaintingStyle.fill;

    final rectBackground = Rect.fromLTWH(
      0,
      -rectHeight / 2,
      maxRectWidth,
      rectHeight,
    );
    //canvas.drawRect(rectBackground, rectBackgroundPaint);

    canvas.drawRRect(
      RRect.fromRectAndRadius(rectBackground, Radius.circular(8)),
      rectBackgroundPaint,
    );
    // Draw power meter outline
    final outlinePaint =
        Paint()
          ..color = Colors.lightGreen
          ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rectBackground, Radius.circular(8)),
      outlinePaint,
    );
    //canvas.drawRect(rectBackground, outlinePaint);

    // Draw power meter fill
    final rectPaint =
        Paint()
          ..color =
              powerColor //.withValues(alpha: 0.7)
          ..style = PaintingStyle.fill;

    final rect = Rect.fromLTWH(
      0,
      -rectHeight / 2,
      currentRectWidth,
      rectHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(8)),
      rectPaint,
    );

    // Draw power level text
    final textPainter = TextPainter(
      text: TextSpan(
        text: powerLevel.toStringAsFixed(1),
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(maxRectWidth / 2 - textPainter.width / 2, -textPainter.height / 2),
    );

    // Restore canvas to original state
    canvas.restore();

    // Draw arrow at end of the line
    _drawArrow(canvas, end, angle, powerColor);
  }

  /// Draw a dashed line to show projectile trajectory
  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    final dashWidth = 5;
    final dashSpace = 5;

    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = sqrt(dx * dx + dy * dy);

    final unitVectorX = dx / distance;
    final unitVectorY = dy / distance;

    final dashCount = (distance / (dashWidth + dashSpace)).floor();

    for (int i = 0; i < dashCount; i++) {
      final dashStart = Offset(
        start.dx + unitVectorX * dashSpace * i,
        start.dy + unitVectorY * dashSpace * i,
      );

      final dashEnd = Offset(
        dashStart.dx + unitVectorX * dashWidth,
        dashStart.dy + unitVectorY * dashWidth,
      );

      canvas.drawLine(dashStart, dashEnd, paint);
    }
  }

  /// Draw an arrow at the end of the line
  void _drawArrow(Canvas canvas, Offset position, double angle, Color color) {
    final arrowPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(angle);

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(-15, -7);
    path.lineTo(-10, 0);
    path.lineTo(-15, 7);
    path.close();

    canvas.drawPath(path, arrowPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) {
    return oldDelegate.start != start ||
        oldDelegate.end != end ||
        oldDelegate.powerLevel != powerLevel ||
        oldDelegate.cameraX != cameraX ||
        oldDelegate.cameraY != cameraY;
  }
}
