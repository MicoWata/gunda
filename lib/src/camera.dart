import 'package:flutter/material.dart';
import 'package:gunda/src/body.dart';
import 'package:gunda/src/game.dart';

/// Camera class that follows the player and handles viewport transformations
class Camera {
  /// The x position of the camera in the game world
  double x = 0;

  /// The y position of the camera in the game world
  double y = 0;

  double viewportWidth;
  double viewportHeight;

  double followSpeed = 0.15;

  /// Constructor for camera
  Camera({required this.viewportWidth, required this.viewportHeight});

  /// Update the camera position to follow the target with smooth movement
  /// but prevent seeing beyond the walls with a fixed camera strategy
  void follow(Body target) {
    // Step 1: Fixed approach - strictly define camera viewport limits
    final maxX = Game.gameWidth - viewportWidth;
    final maxY = Game.gameHeight - viewportHeight;

    // Step 2: Calculate ideal target position (center on player)
    final targetX = target.centerX - viewportWidth / 2;
    final targetY = target.centerY - viewportHeight / 2;

    // Step 3: The critical part - strictly limit the camera target position
    // Calculate how much to move toward target (but not passing map boundaries)
    double moveX = (targetX - x) * followSpeed;
    double moveY = (targetY - y) * followSpeed;

    // Check if new position would exceed boundaries
    double newX = x + moveX;
    double newY = y + moveY;

    // Hard clamp the target values
    if (newX < 0) newX = 0;
    if (newX > maxX) newX = maxX;
    if (newY < 0) newY = 0;
    if (newY > maxY) newY = maxY;

    // Apply the clamped position
    x = newX;
    y = newY;
  }

  void zoomOut() {
    // let's write a zoomOut function AI!
  }

  /// Check if a world rectangle is visible in the viewport
  bool isVisible(double worldX, double worldY, double width, double height) {
    return worldX + width > x &&
        worldX < x + viewportWidth &&
        worldY + height > y &&
        worldY < y + viewportHeight;
  }

  /// Transform a world position to screen position
  Offset worldToScreen(double worldX, double worldY) {
    return Offset(worldX - x, worldY - y);
  }

  /// Transform a world rectangle to screen rectangle
  Rect worldToScreenRect(
    double worldX,
    double worldY,
    double width,
    double height,
  ) {
    final screenPos = worldToScreen(worldX, worldY);
    return Rect.fromLTWH(screenPos.dx, screenPos.dy, width, height);
  }
}
