import 'package:flutter/material.dart';

/// Rectangle representation for collision detection
class Body {
  double x;
  double y;
  double xVelocity;
  double yVelocity;
  double width;
  double height;
  Color color;
  double mass;

  Body({
    required this.x,
    required this.y,
    this.xVelocity = 0,
    this.yVelocity = 0,
    required this.width,
    required this.height,
    required this.color,
    this.mass = 1.0,
  });

  /// Check if this rectangle collides with another
  bool collidesWith(Body other) {
    return x < other.x + other.width &&
        x + width > other.x &&
        y < other.y + other.height &&
        y + height > other.y;
  }

  /// Get rectangle boundaries
  double get left => x;
  double get right => x + width;
  double get top => y;
  double get bottom => y + height;

  /// Get center point
  double get centerX => x + width / 2;
  double get centerY => y + height / 2;

  /// Update position based on velocity
  void update() {
    x += xVelocity;
    y += yVelocity;
  }

  /// Apply impulse (change in momentum) to the rectangle
  void applyImpulse(double forceX, double forceY) {
    xVelocity += forceX / mass;
    yVelocity += forceY / mass;
  }
}
