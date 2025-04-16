import 'dart:math';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:gunda/src/app.dart';
import 'package:gunda/src/ball.dart';
import 'package:gunda/src/body.dart';
import 'package:gunda/src/camera.dart';
import 'package:gunda/src/effect.dart';
import 'package:gunda/src/game.dart';
import 'package:gunda/src/mob.dart';
import 'package:gunda/src/obstacle.dart';
import 'package:gunda/src/player.dart';

class Level {
  static late Size size;

  static final List<Enemy> enemies = [];
  static final List<Projectile> projectiles = [];
  static final List<ImpactParticle> impactParticles = [];
  static final List<Obstacle> obstacles = [];

  static void enter() {
    initializeEnemies();
    initializeObstacles();
  }

  static void initializeEnemies() async {
    await TileMap.loadMap();
    var spotsize = 2400 / 32;

    double maxWidth = Game.gameWidth - Mob.size.width;
    double maxHeight = Game.gameHeight - Mob.size.height;

    enemies.clear();

    for (int x = 0; x < 32; x++) {
      for (int y = 0; y < 32; y++) {
        if (TileMap.map[x][y] == 2) {
          final hue = Game.random.nextInt(360);
          final color =
              HSVColor.fromAHSV(1.0, hue.toDouble(), 0.7, 0.9).toColor();

          Enemy enemy = Enemy(
            body: Body(
              x: x * spotsize,
              y: y * spotsize,

              xVelocity:
                  Game.random.nextDouble() * 2 - 1, // Random initial velocity
              yVelocity:
                  Game.random.nextDouble() * 2 - 1, // Random initial velocity
              width: Mob.size.width, // Slightly smaller than target
              height: Mob.size.height, // Slightly smaller than target
              color: color,
              mass: Mob.mass, // Slightly lighter than target
            ),
          );
          enemies.add(enemy);

          //double rockSize =
          //    (spotsize / 2) + Game.random.nextDouble() * (spotsize / 2);
          //double rockX = x * spotsize;
          //double rockY = y * spotsize;
          //obstacles.add(
          //  ObstacleFactory.createRock(x: rockX, y: rockY, size: rockSize),
          //);
        }
      }
    }
    //print(enemies);
    //// Create new enemies
    //for (int i = 0; i < Mob.max; i++) {
    //  // Generate random color shade
    //  final hue = Game.random.nextInt(360);
    //  final color = HSVColor.fromAHSV(1.0, hue.toDouble(), 0.7, 0.9).toColor();
    //
    //  // Create enemy with random position but avoid player's initial position
    //  double enemyX, enemyY;
    //  do {
    //    enemyX = Game.random.nextDouble() * maxWidth;
    //    enemyY = Game.random.nextDouble() * maxHeight;
    //  } while (isNearPlayer(
    //    enemyX,
    //    enemyY,
    //    300,
    //  )); // Minimum distance of 300 from player
    //
    //  Enemy enemy = Enemy(
    //    body: Body(
    //      x: enemyX,
    //      y: enemyY,
    //      xVelocity:
    //          Game.random.nextDouble() * 2 - 1, // Random initial velocity
    //      yVelocity:
    //          Game.random.nextDouble() * 2 - 1, // Random initial velocity
    //      width: Mob.size.width * 0.8, // Slightly smaller than target
    //      height: Mob.size.height * 0.8, // Slightly smaller than target
    //      color: color,
    //      mass: Mob.mass, // Slightly lighter than target
    //    ),
    //  );
    //
    //  enemies.add(enemy);
    //  //enemyCanShoot.add(true); // Each enemy can shoot initially
    //  //enemyShootCooldowns.add(
    //  //  Mob.cooldown + Game.random.nextInt(1000),
    //  //); // Stagger cooldowns
    //}
  }

  static void walls() {
    obstacles.add(
      ObstacleFactory.createWall(
        x: -20,
        y: -20,
        width: 20,
        height: Game.gameHeight + 40,
      ),
    );

    // Right wall
    obstacles.add(
      ObstacleFactory.createWall(
        x: Game.gameWidth,
        y: -20,
        width: 20,
        height: Game.gameHeight + 40,
      ),
    );

    // Top wall
    obstacles.add(
      ObstacleFactory.createWall(
        x: -20,
        y: -20,
        width: Game.gameWidth + 40,
        height: 20,
      ),
    );

    // Bottom wall
    obstacles.add(
      ObstacleFactory.createWall(
        x: -20,
        y: Game.gameHeight,
        width: Game.gameWidth + 40,
        height: 20,
      ),
    );
  }

  static void block() {
    obstacles.add(
      ObstacleFactory.createMetalBarrier(
        x: Game.gameWidth / 2 - 100,
        y: Game.gameHeight / 2 - 100,
        width: 200,
        height: 200,
      ),
    );
  }

  static void rocks() {
    var spotsize = 2400 / 32;

    for (int x = 0; x < 32; x++) {
      for (int y = 0; y < 32; y++) {
        if (TileMap.map[x][y] == 1) {
          double rockSize =
              (spotsize / 2) + Game.random.nextDouble() * (spotsize / 2);
          double rockX = x * spotsize;
          double rockY = y * spotsize;
          obstacles.add(
            ObstacleFactory.createRock(x: rockX, y: rockY, size: rockSize),
          );
        }
      }
    }
    // Random rocks
    //for (int i = 0; i < 15; i++) {
    //  double rockSize = 30 + Game.random.nextDouble() * 70;
    //  double rockX = Game.random.nextDouble() * (Game.gameWidth - rockSize);
    //  double rockY = Game.random.nextDouble() * (Game.gameHeight - rockSize);
    //
    //  // Ensure rocks aren't placed near the player starting position
    //  if (!isNearPlayer(rockX, rockY, 350)) {
    //    obstacles.add(
    //      ObstacleFactory.createRock(x: rockX, y: rockY, size: rockSize),
    //    );
    //  }
    //}
  }

  static void initializeObstacles() async {
    await TileMap.loadMap();
    obstacles.clear();

    walls();
    //block();
    rocks();
  }

  static bool isNearPlayer(double x, double y, double minDistance) {
    if (!Player.body.x.isNaN) {
      // Make sure player is initialized
      double playerCenterX = Game.gameWidth / 2;
      double playerCenterY = Game.gameHeight / 2;
      double distance = sqrt(
        pow(x - playerCenterX, 2) + pow(y - playerCenterY, 2),
      );
      return distance < minDistance;
    }
    return false;
  }

  static Widget buildGrid(double width, double height, Camera camera) {
    // Always update when camera moves
    //size = Size(width, height);

    //return Container();
    return CustomPaint(
      size: size,
      painter: GridPainter(
        gridSize: 100, // Larger grid size for the bigger map
        lineColor: Colors.brown.shade900,
        cameraX: camera.x,
        cameraY: camera.y,
        gameWidth: Game.gameWidth,
        gameHeight: Game.gameHeight,
      ),
    );
  }
}

class TileMap {
  static var level = 1;
  static var tileSize = 64.0;
  static List<List<int>> map = [];

  static Future<void> loadMap() async {
    final String source =
        TileMap.level == 0
            ? 'assets/images/Level1.txt'
            : 'assets/images/level1.txt';
    final String mapData = await rootBundle.loadString(source);
    final List<String> rows = mapData.trim().split('\n');
    map =
        rows
            .map((row) => row.trim().split(' ').map(int.parse).toList())
            .toList();
  }

  //static Point<int> getTilePosition(double screenX, double screenY) {
  //  return Point<int>(
  //    (screenX ~/ TileMap.tileSize),
  //    (screenY ~/ TileMap.tileSize),
  //  );
  //}
  //
  //static Point<double> getScreenPosition(int tileX, int tileY) {
  //  return Point<double>(tileX * TileMap.tileSize, tileY * TileMap.tileSize);
  //}
  //
  //static bool isValidTile(int x, int y) {
  //  return y >= 0 && y < map.length && x >= 0 && x < map[0].length;
  //}
  //
  //static int getTileType(int x, int y) {
  //  if (!isValidTile(x, y)) return -1;
  //  return map[y][x];
  //}
}

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
          ..strokeWidth = 2.0;

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
            ..strokeWidth = 4.0
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
