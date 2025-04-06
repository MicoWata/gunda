import 'package:flutter/material.dart';
import 'package:gunda/src/body.dart';
import 'package:gunda/src/camera.dart';

/// A static obstacle that doesn't move but can be collided with
class Obstacle {
  final Body body;
  final BorderRadius? borderRadius;
  final BoxShadow? shadow;
  final Color? borderColor;
  final double borderWidth;

  Obstacle({
    required double x,
    required double y,
    required double width,
    required double height,
    required Color color,
    this.borderRadius,
    this.shadow,
    this.borderColor,
    this.borderWidth = 0,
  }) : body = Body(
          x: x,
          y: y,
          width: width,
          height: height,
          color: color,
          idle: true, // Obstacles don't move
          mass: double.infinity, // Infinite mass means they don't move when hit
        );

  /// Build the widget representation of this obstacle
  static Widget build(Obstacle obstacle, Camera camera) {
    return Positioned(
      left: obstacle.body.x - camera.x,
      top: obstacle.body.y - camera.y,
      child: Container(
        width: obstacle.body.width,
        height: obstacle.body.height,
        decoration: BoxDecoration(
          color: obstacle.body.color,
          borderRadius: obstacle.borderRadius,
          border: obstacle.borderColor != null
              ? Border.all(
                  color: obstacle.borderColor!,
                  width: obstacle.borderWidth,
                )
              : null,
          boxShadow: obstacle.shadow != null ? [obstacle.shadow!] : null,
        ),
      ),
    );
  }
}

/// Factory class for creating different types of obstacles
class ObstacleFactory {
  /// Create a basic wall obstacle
  static Obstacle createWall({
    required double x,
    required double y,
    required double width,
    required double height,
    Color color = const Color(0xFF555555),
  }) {
    return Obstacle(
      x: x,
      y: y,
      width: width,
      height: height,
      color: color,
      borderRadius: BorderRadius.circular(4),
      shadow: const BoxShadow(
        color: Colors.black26,
        blurRadius: 5,
        offset: Offset(2, 2),
      ),
    );
  }

  /// Create a metal barrier obstacle
  static Obstacle createMetalBarrier({
    required double x,
    required double y,
    required double width,
    required double height,
  }) {
    return Obstacle(
      x: x,
      y: y,
      width: width,
      height: height,
      color: const Color(0xFF888888),
      borderRadius: BorderRadius.circular(2),
      borderColor: const Color(0xFFAAAAAA),
      borderWidth: 2,
      shadow: const BoxShadow(
        color: Colors.black38,
        blurRadius: 3,
        offset: Offset(1, 1),
      ),
    );
  }

  /// Create a rock obstacle
  static Obstacle createRock({
    required double x,
    required double y,
    required double size,
  }) {
    return Obstacle(
      x: x,
      y: y,
      width: size,
      height: size,
      color: const Color(0xFF7D6C63),
      borderRadius: BorderRadius.circular(size / 3),
      shadow: const BoxShadow(
        color: Colors.black45,
        blurRadius: 4,
        offset: Offset(2, 2),
      ),
    );
  }
}