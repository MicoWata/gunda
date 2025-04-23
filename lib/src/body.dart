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
  bool idle;

  Body({
    required this.x,
    required this.y,
    this.xVelocity = 0,
    this.yVelocity = 0,
    required this.width,
    required this.height,
    required this.color,
    this.mass = 1.0,
    this.idle = false,
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

  /// Get corner points
  Offset get topLeft => Offset(left, top);
  Offset get topRight => Offset(right, top);
  Offset get bottomLeft => Offset(left, bottom);
  Offset get bottomRight => Offset(right, bottom);

  /// Get center point
  Offset get center => Offset(centerX, centerY);
  double get centerX => x + width / 2;
  double get centerY => y + height / 2;

  /// Update position based on velocity
  void update() {
    x += xVelocity;
    y += yVelocity;
  }

  /// Checks if a point is inside the body's bounds.
  bool contains(Offset point) {
    return point.dx >= left && point.dx <= right && point.dy >= top && point.dy <= bottom;
  }

  /// Apply impulse (change in momentum) to the rectangle
  void applyImpulse(double forceX, double forceY) {
    xVelocity += forceX / mass;
    yVelocity += forceY / mass;
  }

  /// Convert Body object to a JSON map
  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
        'xVelocity': xVelocity,
        'yVelocity': yVelocity,
        'width': width,
        'height': height,
        'color': color.value, // Save color as integer value
        'mass': mass,
        'idle': idle,
      };

  /// Create Body object from a JSON map
  factory Body.fromJson(Map<String, dynamic> json) => Body(
        x: (json['x'] as num).toDouble(), // Ensure double type
        y: (json['y'] as num).toDouble(), // Ensure double type
        xVelocity: (json['xVelocity'] as num).toDouble(), // Ensure double type
        yVelocity: (json['yVelocity'] as num).toDouble(), // Ensure double type
        width: (json['width'] as num).toDouble(), // Ensure double type
        height: (json['height'] as num).toDouble(), // Ensure double type
        color: Color(json['color'] as int), // Ensure int type
        mass: (json['mass'] as num).toDouble(), // Ensure double type
        idle: json['idle'] as bool, // Ensure bool type
      );
}
