import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:gunda/src/ball.dart';
import 'package:gunda/src/camera.dart';
import 'package:gunda/src/effect.dart';
import 'package:gunda/src/body.dart'; // Import Body
import 'package:gunda/src/game.dart';
import 'package:gunda/src/level.dart';
import 'package:gunda/src/mob.dart'; // Import Enemy
import 'package:gunda/src/player.dart';

enum Weapons { sword, cannon }

class Weapon {
  static ui.Image? shotgunImage; // To store the loaded image

  static const double minPower = 8.0;
  static const double maxPower = 30.0;
  static const double powerIncreaseRate = 0.3;

  // Cooldown for shooting
  static bool canShoot = true;
  static final cooldown = 300; // milliseconds

  static Weapons kind = Weapons.sword;
  // Power meter for shooting
  static double power = Weapon.minPower;
  static bool isChargingShot = false;
  static bool show = true;
  static bool slicing = false; // Start not slicing

  // Slice animation state
  static const int _sliceDuration = 300; // milliseconds
  static const double _sliceDistance = 60.0; // pixels sword extends
  static int _sliceStartTime = 0;
  static Offset _currentSliceOffset = Offset.zero;
  static final Set<Enemy> _hitEnemiesThisSlice = {}; // Track enemies hit per slice


  /// Loads necessary image assets for the weapon.
  static Future<void> loadAssets() async {
    final completer = Completer<ui.Image>();
    final imageProvider = AssetImage('assets/images/shotgun.png');
    imageProvider
        .resolve(const ImageConfiguration())
        .addListener(
          ImageStreamListener((ImageInfo info, bool _) {
            if (!completer.isCompleted) {
              completer.complete(info.image);
              shotgunImage = info.image;
            }
          }),
        );
    // Consider adding error handling here if the image fails to load
    await completer.future; // Wait for the image to load
  }

  static Offset _getLimitedLineEndPoint(
    Offset start,
    Offset end,
    double maxLength,
  ) {
    double dx = end.dx - start.dx;
    double dy = end.dy - start.dy;
    double distance = sqrt(dx * dx + dy * dy);

    //if (distance <= maxLength) {
    //  return end;
    //} else {
    double ratio = maxLength / distance;
    return Offset(start.dx + dx * ratio, start.dy + dy * ratio);
    //}
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
        radius: Ball.projectileRadius * (power / 8),
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

  /// Updates weapon state, like slice animation. Called from game loop.
  static void update() {
    if (slicing) {
      final elapsedTime = DateTime.now().millisecondsSinceEpoch - _sliceStartTime;

      if (elapsedTime >= _sliceDuration) {
        // Slice finished
        slicing = false;
        _currentSliceOffset = Offset.zero;
      } else {
        // Calculate slice progress (0.0 to 1.0)
        final progress = elapsedTime / _sliceDuration;

        // Calculate extension factor (0 -> 1 -> 0 using sine wave)
        final extensionFactor = sin(progress * pi); // Smooth in-out

        // Calculate direction from player center towards mouse
        final playerCenter = Offset(Player.body.centerX, Player.body.centerY);
        // Use the pre-calculated world mouse position from Player class
        final worldMousePosition = Player.worldMousePosition;
        final dx = worldMousePosition.dx - playerCenter.dx;
        final dy = worldMousePosition.dy - playerCenter.dy;
        final distance = sqrt(dx * dx + dy * dy);

        Offset direction = Offset.zero;
        if (distance > 0) {
          direction = Offset(dx / distance, dy / distance);
        } else {
          direction = const Offset(1, 0); // Default direction if mouse is at center
        }


        // Calculate the current offset based on direction, distance, and animation factor
        _currentSliceOffset = direction * _sliceDistance * extensionFactor;

        // --- Sword Collision Detection ---
        // Calculate world coordinates of the sword's hilt and tip
        // final playerCenter = Offset(Player.body.centerX, Player.body.centerY); // Already defined above
        final worldHilt = playerCenter + _currentSliceOffset;
        final worldTip = worldHilt + (direction * 70.0); // Use the same length as the visual representation

        // Check collision with enemies
        for (int i = Level.enemies.length - 1; i >= 0; i--) {
          Enemy enemy = Level.enemies[i];
          // Ensure enemy has a body and isn't already dead or hit this slice
          if (enemy.body != null && !enemy.dead && !_hitEnemiesThisSlice.contains(enemy)) {
            if (_lineIntersectsRect(worldHilt, worldTip, enemy.body!)) {
              // Collision detected!
              _hitEnemiesThisSlice.add(enemy); // Mark as hit for this slice

              // Apply damage (placeholder - needs Enemy.takeDamage method)
              // enemy.takeDamage(1); // Example damage value
              print('Sword hit enemy $i!'); // Placeholder action

              // Apply knockback (away from player center)
              final diff = enemy.body!.center - playerCenter;
              final distance = diff.distance; // Magnitude of the difference vector
              Offset knockbackDirection = Offset.zero;
              if (distance > 0) { // Avoid division by zero
                knockbackDirection = diff / distance; // Normalize the vector
              }
              final knockbackForce = 15.0; // Adjust force as needed
              enemy.body!.applyImpulse(
                knockbackDirection.dx * knockbackForce,
                knockbackDirection.dy * knockbackForce,
              );

              // Trigger impact effect
              Effect.impact(
                enemy.body!.centerX,
                enemy.body!.centerY,
                Colors.white, // Sword impact color
                0.8, // Impact size/intensity
              );
            }
          }
        }
        // --- End Sword Collision Detection ---
      }
    } else {
      _currentSliceOffset = Offset.zero; // Ensure offset is zero when not slicing
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

  static void slice() {
    // Start slicing only if using sword and not already slicing
    if (kind == Weapons.sword && !slicing) {
      slicing = true;
      _sliceStartTime = DateTime.now().millisecondsSinceEpoch;
      _currentSliceOffset = Offset.zero; // Reset offset at start
      _hitEnemiesThisSlice.clear(); // Clear hit enemies for the new slice

      // TODO: Add cooldown for slicing?
    }
  }

  static CustomPaint buildCannon(
    double screenWidth,
    double screenHeight,
    Offset mousePosition,
    Camera camera,
  ) {
    return CustomPaint(
      size: Size(screenWidth, screenHeight),
      painter: SwordPainter(
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
          70.0, // Longer aiming line for larger map
        ),
        powerLevel: isChargingShot ? power : minPower,
        cameraX: camera.x,
        cameraY: camera.y,
      ),
    );
  }

  static CustomPaint buildSword(
    double screenWidth,
    double screenHeight,
    Offset mousePosition,
    Camera camera,
  ) {
    // Base position of the sword hilt (player center in screen coordinates)
    final baseHiltScreen = Offset(
      Player.body.centerX - camera.x,
      Player.body.centerY - camera.y,
    );

    // Calculate the aiming vector (from player center towards mouse, limited length)
    // Note: _getLimitedLineEndPoint expects screen coordinates
    final aimEndPointScreen = _getLimitedLineEndPoint(
      baseHiltScreen,
      mousePosition, // Mouse position is already in screen coordinates
      70.0,
    );
    final aimVectorScreen = aimEndPointScreen - baseHiltScreen;

    // Apply the slice offset (which is calculated in world coordinates, so no camera adjustment needed here)
    // The offset is applied relative to the player's center.
    final currentHiltScreen = baseHiltScreen + _currentSliceOffset;
    final currentTipScreen = currentHiltScreen + aimVectorScreen; // Tip moves with the hilt

    return CustomPaint(
      size: Size(screenWidth, screenHeight),
      painter: SwordPainter(
        start: currentHiltScreen, // Use the animated hilt position
        end: currentTipScreen,   // Use the animated tip position
        powerLevel: power, // Sword doesn't use power level visually like cannon? Maybe remove later.
        cameraX: camera.x, // Pass camera for potential future use in painter
        cameraY: camera.y,
      ),
    );
  }

  static Widget build(
    double screenWidth,
    double screenHeight,
    Offset mousePosition,
    Camera camera,
  ) {
    if (!Game.over) {
      return kind == Weapons.cannon
          ? buildCannon(screenWidth, screenHeight, mousePosition, camera)
          : buildSword(screenWidth, screenHeight, mousePosition, camera);
    } else {
      return Container();
    }
  }

  // --- Collision Helper Methods ---

  // Simple Line Segment vs. Axis-Aligned Bounding Box (AABB) intersection test
  // This is a basic check and might not be perfectly accurate for all edge cases,
  // but it's a good starting point.
  static bool _lineIntersectsRect(Offset p1, Offset p2, Body rect) {
    // Check if either endpoint is inside the rectangle
    if (rect.contains(p1) || rect.contains(p2)) {
      return true;
    }

    // Check for intersection with each of the 4 rectangle edges
    // Using a simplified approach: check if line crosses the rectangle's x and y ranges
    double minX = min(p1.dx, p2.dx);
    double maxX = max(p1.dx, p2.dx);
    double minY = min(p1.dy, p2.dy);
    double maxY = max(p1.dy, p2.dy);

    // Check if the line's bounding box overlaps the rectangle's bounding box
    if (maxX < rect.left || minX > rect.right || maxY < rect.top || minY > rect.bottom) {
      return false; // No overlap possible
    }

    // More robust checks (e.g., Liang-Barsky or separating axis theorem) could be used here
    // for better accuracy, especially for lines that pass through without endpoints inside.
    // For now, we'll consider overlap of bounding boxes as a potential intersection.
    // This might lead to some false positives if the line passes *near* but not *through*.

    // A slightly better check: Test intersection with diagonals (covers more cases)
    bool intersectsDiagonal1 = _lineSegmentIntersection(p1, p2, rect.topLeft, rect.bottomRight);
    bool intersectsDiagonal2 = _lineSegmentIntersection(p1, p2, rect.topRight, rect.bottomLeft);

    // Also check intersection with the rectangle's sides explicitly (more robust)
    bool intersectsTop = _lineSegmentIntersection(p1, p2, rect.topLeft, rect.topRight);
    bool intersectsBottom = _lineSegmentIntersection(p1, p2, rect.bottomLeft, rect.bottomRight);
    bool intersectsLeft = _lineSegmentIntersection(p1, p2, rect.topLeft, rect.bottomLeft);
    bool intersectsRight = _lineSegmentIntersection(p1, p2, rect.topRight, rect.bottomRight);


    return intersectsDiagonal1 || intersectsDiagonal2 || intersectsTop || intersectsBottom || intersectsLeft || intersectsRight;
  }

  // Helper to check if two line segments intersect
  // Source: Adapted from various geometry algorithms (e.g., StackOverflow)
  static bool _lineSegmentIntersection(Offset p1, Offset p2, Offset p3, Offset p4) {
    double det = (p2.dx - p1.dx) * (p4.dy - p3.dy) - (p2.dy - p1.dy) * (p4.dx - p3.dx);
    if (det.abs() < 1e-9) { // Use tolerance for floating point comparison
      return false; // Parallel or collinear lines
    } else {
      double t = ((p3.dx - p1.dx) * (p4.dy - p3.dy) - (p3.dy - p1.dy) * (p4.dx - p3.dx)) / det;
      double u = -((p2.dx - p1.dx) * (p3.dy - p1.dy) - (p2.dy - p1.dy) * (p3.dx - p1.dx)) / det;

      // Use tolerance for floating point comparison
      const double epsilon = 1e-9;
      return t >= -epsilon && t <= 1.0 + epsilon && u >= -epsilon && u <= 1.0 + epsilon; // Intersection point is within both segments (with tolerance)
    }
  }

}

/// Custom painter to draw an aiming line with power meter
class SwordPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final double powerLevel;
  final double minPower;
  final double maxPower;
  final double cameraX;
  final double cameraY;
  //late ui.Image shotgun; // Removed instance variable
  //static bool loaded = false; // Removed static flag

  SwordPainter({
    required this.start,
    required this.end,
    required this.powerLevel,
    this.minPower = Weapon.minPower,
    this.maxPower = Weapon.maxPower,
    this.cameraX = 0,
    this.cameraY = 0,
  }); // Removed constructor body

  // Removed _loadWeaponImage method
  // Removed _loadShotgun method

  @override
  void paint(Canvas canvas, Size size) {
    // Use the statically loaded image, check if it's null
    if (Weapon.show) {
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

      // Create power meter properties
      final rectHeight = 25.0;
      final maxRectWidth = lineLength;
      final currentRectWidth = maxRectWidth * powerPercentage;

      // Save canvas state before rotation
      canvas.save();

      // Translate to start point and rotate
      canvas.translate(start.dx, start.dy);
      canvas.rotate(angle);

      // Draw power meter background
      //final rectBackgroundPaint =
      //    Paint()
      //      ..color =
      //          Colors
      //              .grey //.withValues(alpha: 0.3)
      //      ..style = PaintingStyle.fill;

      final rectBackground = Rect.fromLTWH(
        0,
        -rectHeight / 2,
        maxRectWidth,
        rectHeight,
      );
      //canvas.drawRect(rectBackground, rectBackgroundPaint);

      //canvas.drawRRect(
      //  RRect.fromRectAndRadius(rectBackground, Radius.circular(8)),
      //  rectBackgroundPaint,
      //);
      // Draw power meter outline
      final outlinePaint =
          Paint()
            ..color = powerColor
            ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(rectBackground, Radius.circular(8)),
        outlinePaint,
      );

      // Draw power meter fill
      //final rectPaint =
      //    Paint()
      //      ..color =
      //          powerColor //.withValues(alpha: 0.7)
      //      ..style = PaintingStyle.fill;
      //
      //final rect = Rect.fromLTWH(
      //  0,
      //  -rectHeight / 2,
      //  currentRectWidth,
      //  rectHeight,
      //);
      //canvas.drawRRect(
      //  RRect.fromRectAndRadius(rect, Radius.circular(8)),
      //  rectPaint,
      //);
      // Use the static image directly
      // No need to check 'loaded' here as it's checked at the start of paint
      //canvas.drawImageRect(
      //  Weapon.shotgunImage!, // Use the non-null assertion operator (!)
      //  //Rect.fromCenter(
      //  //  center: Offset(0, 0),
      //  //  width: shotgun!.width.toDouble(),
      //  //  height: shotgun!.height.toDouble(),
      //  //),
      //  Rect.fromLTWH(
      //    0,
      //    0,
      //    Weapon.shotgunImage!.width.toDouble(), // Use static image dimensions
      //    Weapon.shotgunImage!.height.toDouble(), // Use static image dimensions
      //  ),
      //Rect.fromLTWH(rectBackground.left, rectBackground.top - 16, 96, 96),
      ////rectBackground,
      ////Rect.fromCenter(center: Offset(dx - 32, dy - 32), width: 64, height: 64),
      //Rect.fromLTWH(dx - 0, dy - 0, 64, 64),
      //Paint()..filterQuality = FilterQuality.none,
      //);
      //} <--- REMOVE THIS EXTRA BRACE
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
        Offset(
          maxRectWidth / 2 - textPainter.width / 2,
          -textPainter.height / 2,
        ),
      );

      // Draw arrow at end of the line (relative to the rotated canvas)
      // Note: 'end' is in screen coordinates, need to adjust for rotation/translation
      // We want the arrow at the end of the power meter line (length: maxRectWidth)
      //_drawArrow(canvas, Offset(maxRectWidth, 0), angle, powerColor);

      // Restore canvas to original state
      canvas.restore();

      // Draw arrow at end of the line - MOVED BEFORE canvas.restore()
      // _drawArrow(canvas, end, angle, powerColor);
    }
  }

  @override
  bool shouldRepaint(SwordPainter oldDelegate) {
    // Compare old delegate's properties with the current instance's properties
    return oldDelegate.start != start ||
        oldDelegate.end != end ||
        oldDelegate.powerLevel != powerLevel ||
        oldDelegate.cameraX != cameraX ||
        oldDelegate.cameraY != cameraY;
  }

  // --- Helper methods moved to Weapon class ---
  // static bool _lineIntersectsRect(...) { ... }
  // static bool _lineSegmentIntersection(...) { ... }

}

class LinePainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final double powerLevel;
  final double minPower;
  final double maxPower;
  final double cameraX;
  final double cameraY;
  //late ui.Image shotgun; // Removed instance variable
  //static bool loaded = false; // Removed static flag

  LinePainter({
    required this.start,
    required this.end,
    required this.powerLevel,
    this.minPower = Weapon.minPower,
    this.maxPower = Weapon.maxPower,
    this.cameraX = 0,
    this.cameraY = 0,
  }); // Removed constructor body

  // Removed _loadWeaponImage method
  // Removed _loadShotgun method

  @override
  void paint(Canvas canvas, Size size) {
    // Use the statically loaded image, check if it's null
    if (Weapon.shotgunImage != null && Weapon.show) {
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
      final rectHeight = 25.0;
      final maxRectWidth = lineLength;
      final currentRectWidth = maxRectWidth * powerPercentage;

      // Save canvas state before rotation
      canvas.save();

      // Translate to start point and rotate
      canvas.translate(start.dx, start.dy);
      canvas.rotate(angle);

      // Draw power meter background
      //final rectBackgroundPaint =
      //    Paint()
      //      ..color =
      //          Colors
      //              .grey //.withValues(alpha: 0.3)
      //      ..style = PaintingStyle.fill;

      final rectBackground = Rect.fromLTWH(
        0,
        -rectHeight / 2,
        maxRectWidth,
        rectHeight,
      );
      //canvas.drawRect(rectBackground, rectBackgroundPaint);

      //canvas.drawRRect(
      //  RRect.fromRectAndRadius(rectBackground, Radius.circular(8)),
      //  rectBackgroundPaint,
      //);
      // Draw power meter outline
      //final outlinePaint =
      //    Paint()
      //      ..color = Colors.lightGreen
      //      ..style = PaintingStyle.fill;
      //
      //canvas.drawRRect(
      //  RRect.fromRectAndRadius(rectBackground, Radius.circular(8)),
      //  outlinePaint,
      //);
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
      // Use the static image directly
      // No need to check 'loaded' here as it's checked at the start of paint
      canvas.drawImageRect(
        Weapon.shotgunImage!, // Use the non-null assertion operator (!)
        //Rect.fromCenter(
        //  center: Offset(0, 0),
        //  width: shotgun!.width.toDouble(),
        //  height: shotgun!.height.toDouble(),
        //),
        Rect.fromLTWH(
          0,
          0,
          Weapon.shotgunImage!.width.toDouble(), // Use static image dimensions
          Weapon.shotgunImage!.height.toDouble(), // Use static image dimensions
        ),
        Rect.fromLTWH(rectBackground.left, rectBackground.top - 16, 96, 96),
        //rectBackground,
        //Rect.fromCenter(center: Offset(dx - 32, dy - 32), width: 64, height: 64),
        //Rect.fromLTWH(dx - 0, dy - 0, 64, 64),
        Paint()..filterQuality = FilterQuality.none,
      );
      //} <--- REMOVE THIS EXTRA BRACE
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
        Offset(
          maxRectWidth / 2 - textPainter.width / 2,
          -textPainter.height / 2,
        ),
      );

      // Draw arrow at end of the line (relative to the rotated canvas)
      // Note: 'end' is in screen coordinates, need to adjust for rotation/translation
      // We want the arrow at the end of the power meter line (length: maxRectWidth)
      _drawArrow(canvas, Offset(maxRectWidth, 0), angle, powerColor);

      // Restore canvas to original state
      canvas.restore();

      // Draw arrow at end of the line - MOVED BEFORE canvas.restore()
      // _drawArrow(canvas, end, angle, powerColor);
    }
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
  bool shouldRepaint(SwordPainter oldDelegate) {
    // Compare old delegate's properties with the current instance's properties
    return oldDelegate.start != start ||
        oldDelegate.end != end ||
        oldDelegate.powerLevel != powerLevel ||
        oldDelegate.cameraX != cameraX ||
        oldDelegate.cameraY != cameraY;
  }
}
