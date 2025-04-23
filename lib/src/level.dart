import 'dart:math';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:gunda/src/ball.dart';
import 'package:gunda/src/body.dart';
import 'package:gunda/src/camera.dart';
import 'package:gunda/src/drop.dart';
import 'package:gunda/src/effect.dart';
import 'package:gunda/src/game.dart';
import 'package:gunda/src/mob.dart';
import 'package:gunda/src/obstacle.dart';
import 'package:gunda/src/player.dart';

class Zone {
  String map;
  int allMob;
  int rows = 32;
  int columns = 32;

  Zone(this.map, this.allMob);
}

class Level {
  static late Size size;
  static late Offset playerStart;

  static final List<Enemy> enemies = [];
  static final List<Projectile> projectiles = [];
  static final List<ImpactParticle> impactParticles = [];
  static final List<Obstacle> obstacles = [];
  static final List<Drop> drops = [];

  static bool done = false;
  static int maxMob = 0;
  static int allMob = 0;
  static int remaining = allMob;
  static int benching = allMob - maxMob;

  static List<Zone> zones = [
    Zone('assets/levels/level0.txt', 2),
    Zone('assets/levels/level1.txt', 3),
    Zone('assets/levels/level2.txt', 4),
  ];

  static void enter() {
    Zone zone = zones[Game.level];

    allMob = zone.allMob;

    done = false;
    enemies.clear();
    projectiles.clear();
    impactParticles.clear();
    obstacles.clear();
    drops.clear();

    initializeEnemies();
    initializeObstacles();

    remaining = allMob;
  }

  static void initializeEnemies() async {
    await TileMap.loadMap();

    var spotsize = Game.gameWidth / 32;

    enemies.clear();

    maxMob = 0;

    for (int x = 0; x < 32; x++) {
      for (int y = 0; y < 32; y++) {
        int mob = TileMap.map[y][x];

        if (mob == 2 || mob == 3 || mob == 4) {
          final hue = Game.random.nextInt(360);
          final color =
              HSVColor.fromAHSV(1.0, hue.toDouble(), 0.7, 0.9).toColor();

          Ennemies kind = switch (mob) {
            2 => Ennemies.dumb,
            3 => Ennemies.wild,
            4 => Ennemies.mad,
            _ => Ennemies.dumb,
          };

          Enemy enemy = Enemy(
            body: Body(
              x: x * spotsize,
              y: y * spotsize,
              xVelocity:
                  Game.random.nextDouble() * 2 - 1, // Random initial velocity
              yVelocity:
                  Game.random.nextDouble() * 2 - 1, // Random initial velocity
              width: Player.body.width, // Slightly smaller than target
              height: Player.body.height, // Slightly smaller than target
              color: color,
              mass: Mob.mass, // Slightly lighter than target
            ),
            kind: kind,
          );

          enemies.add(enemy);

          maxMob++;
        } else if (TileMap.map[y][x] == 9) {
          playerStart = Offset(x.toDouble(), y.toDouble());
          Player.body.x =
              playerStart.dx * Game.gameWidth / Level.zones[Game.level].columns;
          Player.body.y =
              playerStart.dy * Game.gameHeight / Level.zones[Game.level].rows;
        }
      }
    }
    benching = allMob - maxMob;
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
    var spotsize = Game.gameWidth / 32;

    for (int x = 0; x < 32; x++) {
      for (int y = 0; y < 32; y++) {
        if (TileMap.map[y][x] == 1) {
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
  //static var level = 0;
  static var tileSize = 64.0;
  static List<List<int>> map = [];

  static Future<void> loadMap() async {
    final String source = Level.zones[Game.level].map;
    //final String source = 'assets/images/level1.txt';
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
