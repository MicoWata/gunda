import 'package:flutter/material.dart';
import 'package:gunda/src/app.dart';
import 'package:gunda/src/camera.dart';
import 'package:gunda/src/game.dart';
import 'package:gunda/src/level.dart';
import 'package:gunda/src/mob.dart';
import 'package:gunda/src/player.dart';

class Minimap {
  static Widget build(Camera camera, bool showSlowMotion) {
    return Positioned(
      bottom: 20,
      left: 20,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 5,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //...Level.drops.map(
            //  (drop) => Text(
            //    drop.used
            //        ? "USED"
            //        : "${drop.body.x.toStringAsFixed(0)}, ${drop.body.y.toStringAsFixed(0)}",
            //    style: const TextStyle(fontSize: 12, color: Colors.white),
            //  ),
            //),

            //Text(
            //  'Projectiles: ${Level.projectiles.length}/${Ball.maxProjectiles}',
            //  style: const TextStyle(fontSize: 14, color: Colors.white),
            //),
            //Text(
            //  'Particles: ${Level.impactParticles.length}',
            //  style: const TextStyle(fontSize: 14, color: Colors.white),
            //),
            //Text(
            //  'Enemies: ${Level.enemies.length}',
            //  style: const TextStyle(fontSize: 14, color: Colors.white),
            //),
            //const SizedBox(height: 5),
            App.mobile
                ? Container()
                : Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Click: Attack',
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                    Text(
                      'W A S D: Move',
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                    Text(
                      'E: Switch Weapon',
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                    Text(
                      'SPACE: Dash',
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                    Text(
                      'ESCAPE: Pause',
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ],
                ),
            // Debugging information
            //Text(
            //  'Map size: ${Game.gameWidth.toInt()}x${Game.gameHeight.toInt()}',
            //  style: const TextStyle(fontSize: 12, color: Colors.white),
            //),
            //Text(
            //  'Player: (${Player.body.x.toInt()}, ${Player.body.y.toInt()})',
            //  style: const TextStyle(fontSize: 12, color: Colors.white),
            //),
            //Text(
            //  'Camera: (${camera.x.toInt()}, ${camera.y.toInt()})',
            //  style: const TextStyle(fontSize: 12, color: Colors.white),
            //),
            const SizedBox(height: 10),
            // Mini-map showing game world and current viewport
            Container(
              width: App.mobile ? 60 : 120,
              height: App.mobile ? 60 : 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                color: Colors.black.withValues(alpha: 0.3),
              ),
              child: CustomPaint(
                painter: _MinimapPainter(
                  gameWidth: Game.gameWidth,
                  gameHeight: Game.gameHeight,
                  viewportWidth: camera.viewportWidth,
                  viewportHeight: camera.viewportHeight,
                  cameraX: camera.x,
                  cameraY: camera.y,
                  playerX: Player.body.centerX,
                  playerY: Player.body.centerY,
                  //targetX: gameState.target.centerX,
                  //targetY: gameState.target.centerY,
                  enemies: Level.enemies,
                ),
              ),
            ),
            //if (showSlowMotion)
            //  const Text(
            //    'SLOW MOTION ACTIVE',
            //    style: TextStyle(
            //      fontSize: 14,
            //      fontWeight: FontWeight.bold,
            //      color: Colors.yellow,
            //    ),
            //  ),
          ],
        ),
      ),
    );
  }
}

/// Painter for the minimap in the game info panel
class _MinimapPainter extends CustomPainter {
  final double gameWidth;
  final double gameHeight;
  final double viewportWidth;
  final double viewportHeight;
  final double cameraX;
  final double cameraY;
  final double playerX;
  final double playerY;
  //final double targetX;
  //final double targetY;
  final List<Enemy> enemies; // Added enemies list

  _MinimapPainter({
    required this.gameWidth,
    required this.gameHeight,
    required this.viewportWidth,
    required this.viewportHeight,
    required this.cameraX,
    required this.cameraY,
    required this.playerX,
    required this.playerY,
    //required this.targetX,
    //required this.targetY,
    this.enemies = const [], // Default to empty list
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate scale factors to fit the game world in the minimap
    final scaleX = size.width / gameWidth;
    final scaleY = size.height / gameHeight;

    // Draw game world background
    final backgroundPaint =
        Paint()
          ..color = Colors.grey.withValues(alpha: 0.3)
          ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );

    // Draw viewport rectangle (camera view)
    //final viewportPaint =
    //    Paint()
    //      ..color = Colors.white.withValues(alpha: 0.5)
    //      ..style = PaintingStyle.stroke
    //      ..strokeWidth = 1;
    //
    //canvas.drawRect(
    //  Rect.fromLTWH(
    //    cameraX * scaleX,
    //    cameraY * scaleY,
    //    viewportWidth * scaleX,
    //    viewportHeight * scaleY,
    //  ),
    //  viewportPaint,
    //);

    // Draw player position
    final playerPaint =
        Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(playerX * scaleX, playerY * scaleY),
      4, // Larger dot for better visibility
      playerPaint,
    );

    // Draw target position
    //final targetPaint =
    //    Paint()
    //      ..color = Colors.red
    //      ..style = PaintingStyle.fill;
    //
    //canvas.drawCircle(
    //  Offset(targetX * scaleX, targetY * scaleY),
    //  4, // Larger dot for better visibility
    //  targetPaint,
    //);

    // Draw enemy positions
    final enemyPaint = Paint()..style = PaintingStyle.fill;

    for (final Enemy enemy in enemies) {
      if (!enemy.dead) {
        // Use enemy's color but ensure visibility
        enemyPaint.color = enemy.body.color.withValues(alpha: 0.9);

        canvas.drawCircle(
          Offset(enemy.body.centerX * scaleX, enemy.body.centerY * scaleY),
          3, // Slightly smaller than player and target
          enemyPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Always repaint when the camera or objects move
  }
}
