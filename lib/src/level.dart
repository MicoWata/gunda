import 'package:flutter/material.dart';
import 'package:gunda/src/camera.dart';
import 'package:gunda/src/game.dart';

import 'dart:math' show sqrt, atan2;
import 'package:gunda/src/weapon.dart';

class Level {
  static Widget? grid;
  static late Size size;

  static Widget buildGrid(double width, double height, Camera camera) {
    // Always update when camera moves
    size = Size(width, height);

    return CustomPaint(
      size: size,
      painter: GridPainter(
        gridSize: 100, // Larger grid size for the bigger map
        lineColor: Colors.grey,
        cameraX: camera.x,
        cameraY: camera.y,
        gameWidth: Game.gameWidth,
        gameHeight: Game.gameHeight,
      ),
    );
  }

  static void clearGrid() {
    grid = null;
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
    final linePaint =
        Paint()
          ..color = Colors.grey.withValues(alpha: 0.7)
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;

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
          ..color = Colors.grey.withValues(alpha: 0.3)
          ..style = PaintingStyle.fill;

    final rectBackground = Rect.fromLTWH(
      0,
      -rectHeight / 2,
      maxRectWidth,
      rectHeight,
    );
    canvas.drawRect(rectBackground, rectBackgroundPaint);

    // Draw power meter fill
    final rectPaint =
        Paint()
          ..color = powerColor.withValues(alpha: 0.7)
          ..style = PaintingStyle.fill;

    final rect = Rect.fromLTWH(
      0,
      -rectHeight / 2,
      currentRectWidth,
      rectHeight,
    );
    canvas.drawRect(rect, rectPaint);

    // Draw power meter outline
    final outlinePaint =
        Paint()
          ..color = Colors.black
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    canvas.drawRect(rectBackground, outlinePaint);

    // Draw power level text
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Power: ${powerLevel.toStringAsFixed(1)}',
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

/// Grid painter for background reference
class GridPainter extends CustomPainter {
  final double gridSize;
  final Color lineColor;
  final double cameraX;
  final double cameraY;
  final double gameWidth;
  final double gameHeight;

  GridPainter({
    required this.gridSize,
    required this.lineColor,
    this.cameraX = 0,
    this.cameraY = 0,
    this.gameWidth = 600,
    this.gameHeight = 600,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = lineColor
          ..strokeWidth = 1.0;

    // Calculate grid offset based on camera position
    final double offsetX = -cameraX % gridSize;
    final double offsetY = -cameraY % gridSize;

    // Draw vertical lines
    for (double x = offsetX; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = offsetY; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw game world boundary with a more distinct visual style
    // Main boundary line
    final Paint boundaryPaint =
        Paint()
          ..color = Colors.red.withValues(alpha: 0.7)
          ..strokeWidth = 3.0
          ..style = PaintingStyle.stroke;

    // Decorative boundary pattern (diagonal stripes)
    final Paint patternPaint =
        Paint()
          ..color = Colors.orange.withValues(alpha: 0.3)
          ..strokeWidth = 8.0
          ..style = PaintingStyle.stroke;

    // Calculate the boundaries in screen space
    final double left = -cameraX;
    final double top = -cameraY;
    final double right = gameWidth - cameraX;
    final double bottom = gameHeight - cameraY;

    // Only draw the boundary if any part of it is visible
    if (right > 0 || bottom > 0 || left < size.width || top < size.height) {
      final Rect boundaryRect = Rect.fromLTRB(left, top, right, bottom);

      // Draw the main boundary rectangle
      canvas.drawRect(boundaryRect, boundaryPaint);

      // Draw decorative pattern along the edges (diagonal stripes)
      const patternGap = 30.0; // Gap between pattern elements

      // Left edge pattern
      if (left >= 0 && left <= size.width) {
        for (
          double y = top - patternGap;
          y <= bottom + patternGap;
          y += patternGap
        ) {
          canvas.drawLine(
            Offset(left, y),
            Offset(left + 12, y + 12),
            patternPaint,
          );
        }
      }

      // Right edge pattern
      if (right >= 0 && right <= size.width) {
        for (
          double y = top - patternGap;
          y <= bottom + patternGap;
          y += patternGap
        ) {
          canvas.drawLine(
            Offset(right, y),
            Offset(right - 12, y + 12),
            patternPaint,
          );
        }
      }

      // Top edge pattern
      if (top >= 0 && top <= size.height) {
        for (
          double x = left - patternGap;
          x <= right + patternGap;
          x += patternGap
        ) {
          canvas.drawLine(
            Offset(x, top),
            Offset(x + 12, top + 12),
            patternPaint,
          );
        }
      }

      // Bottom edge pattern
      if (bottom >= 0 && bottom <= size.height) {
        for (
          double x = left - patternGap;
          x <= right + patternGap;
          x += patternGap
        ) {
          canvas.drawLine(
            Offset(x, bottom),
            Offset(x + 12, bottom - 12),
            patternPaint,
          );
        }
      }

      // Add a darker inner stroke for better visibility against different backgrounds
      final Paint innerStrokePaint =
          Paint()
            ..color = Colors.deepOrange.withValues(alpha: 0.4)
            ..strokeWidth = 1.0
            ..style = PaintingStyle.stroke;

      canvas.drawRect(
        Rect.fromLTRB(left + 3, top + 3, right - 3, bottom - 3),
        innerStrokePaint,
      );
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) {
    return oldDelegate.gridSize != gridSize ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.cameraX != cameraX ||
        oldDelegate.cameraY != cameraY;
  }
}
