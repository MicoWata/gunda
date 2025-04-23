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
          border:
              obstacle.borderColor != null
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

  /// Convert Obstacle object to a JSON map
  Map<String, dynamic> toJson() => {
    'body': body.toJson(),
    // Note: BorderRadius, BoxShadow, Color?, double are harder to serialize directly.
    // For simplicity, we only save the body and recreate visuals based on type/position later,
    // or add more complex serialization (like a 'type' field) if needed.
    // Example: Add a 'type' field if using the factory.
    // 'type': 'wall', // Example
  };

  /// Create Obstacle object from a JSON map
  /// Note: This requires a way to determine the visual properties (type, radius, etc.)
  factory Obstacle.fromJson(Map<String, dynamic> json) {
    // This is a simplified example. You'd need a 'type' field or similar
    // saved in toJson to know which factory method to call or how to set visuals.
    // For now, it just reconstructs a basic obstacle from the body.
    final body = Body.fromJson(json['body'] as Map<String, dynamic>);
    // String type = json['type'] ?? 'wall'; // Example if saving type
    // switch (type) { ... call appropriate factory ... }
    return Obstacle(
      x: body.x,
      y: body.y,
      width: body.width,
      height: body.height,
      color: body.color,
      // Reconstruct other properties based on type or saved data
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
