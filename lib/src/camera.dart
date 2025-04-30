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
  double zoomLevel = 1.0; // Initial zoom level
  static const double minZoom = 0.25; // Minimum zoom out
  static const double maxZoom = 4.0; // Maximum zoom in
  static const double zoomSensitivity = 0.1; // Adjust sensitivity as needed

  double followSpeed = 0.15;

  /// Constructor for camera
  Camera({required this.viewportWidth, required this.viewportHeight});

  /// Adjust the camera's zoom level based on scroll delta
  void zoom(double delta) {
    // Determine zoom direction and apply zoom factor
    // Negative delta usually means scrolling up (zoom in), positive means scrolling down (zoom out)
    double zoomFactor = 1.0 - delta * zoomSensitivity * 0.01; // Adjust multiplier for desired sensitivity

    // Update zoom level and clamp it
    zoomLevel *= zoomFactor;
    zoomLevel = zoomLevel.clamp(minZoom, maxZoom);
  }

  /// Update the camera position to follow the target with smooth movement
  /// but prevent seeing beyond the walls with a fixed camera strategy, considering zoom.
  void follow(Body target) {
    // Calculate effective viewport size based on zoom
    final effectiveViewportWidth = viewportWidth / zoomLevel;
    final effectiveViewportHeight = viewportHeight / zoomLevel;

    // Step 1: Define camera viewport limits based on effective size
    // Ensure maxX/maxY are not negative if zoomed out beyond map size
    final maxX = max(0.0, Game.gameWidth - effectiveViewportWidth);
    final maxY = max(0.0, Game.gameHeight - effectiveViewportHeight);

    // Step 2: Calculate ideal target position (center on player relative to effective viewport)
    final targetX = target.centerX - effectiveViewportWidth / 2;
    final targetY = target.centerY - effectiveViewportHeight / 2;

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

  // Removed zoomOut() as it's replaced by the new zoom() method

  /// Check if a world rectangle is visible in the viewport, considering zoom
  bool isVisible(double worldX, double worldY, double width, double height) {
    // Calculate the effective viewport boundaries in world coordinates
    final effectiveViewportWidth = viewportWidth / zoomLevel;
    final effectiveViewportHeight = viewportHeight / zoomLevel;
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
    double width,
    double height,
  ) {
    final screenPos = worldToScreen(worldX, worldY);
    // Scale width and height by zoom level
    final scaledWidth = width * zoomLevel;
    final scaledHeight = height * zoomLevel;
    return Rect.fromLTWH(screenPos.dx, screenPos.dy, scaledWidth, scaledHeight);
  }
}
