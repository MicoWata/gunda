import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gunda/src/ball.dart';
import 'package:gunda/src/camera.dart';
import 'package:gunda/src/effect.dart';
import 'package:gunda/src/engine.dart';
import 'package:gunda/src/game.dart';
import 'package:gunda/src/level.dart';
import 'package:gunda/src/minimap.dart';
import 'package:gunda/src/mob.dart';
import 'package:gunda/src/obstacle.dart';
import 'package:gunda/src/panel.dart';
import 'package:gunda/src/player.dart';
import 'package:gunda/src/shader.dart';
import 'package:gunda/src/weapon.dart';

class App extends StatefulWidget {
  const App({super.key});
  static late BuildContext appContext;

  static void snack(String message) {
    var snackBar = SnackBar(content: Text(message));

    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    ScaffoldMessenger.of(App.appContext).showSnackBar(snackBar);
  }

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with SingleTickerProviderStateMixin {
  final GlobalKey _gameAreaKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    // Initialize game
    Game.reset();

    // Set up camera with initial viewport size (will be updated in build)
    Game.camera = Camera(viewportWidth: 600.0, viewportHeight: 600.0);

    // Animation loop for smooth movement
    Game.animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16), // ~60fps
    )..addListener(_updatePosition);

    Game.animationController.repeat();
  }

  @override
  void dispose() {
    Game.animationController.dispose();
    //RawKeyboard.instance.removeListener(Player.handleKeyEvent);
    super.dispose();
  }

  void _updatePosition() {
    // Don't update if game is over
    if (Game.over) return;

    // Handle game state updates
    Game.update();

    // Update player movement
    Player.updatePlayerMovement();

    // Update position
    setState(() {
      // Update positions and handle collisions
      Engine.updatePlayerPhysics();

      // Make sure camera follows player (this is the most important part)
      // This must happen after player update and before we render the frame
      Game.camera.follow(Player.body);

      //_updateTargetPhysics();
      //_updateTargetAI();
      //
      // Update enemy positions and behaviors
      Mob.update();

      // Update projectiles and particles
      _updateProjectiles(Size(Game.gameWidth, Game.gameHeight));
      _updateParticles();

      // Handle collisions
      Engine.checkCollisions(Size(Game.gameWidth, Game.gameHeight));
    });
  }

  void _updateProjectiles(Size screenSize) {
    for (int i = Level.projectiles.length - 1; i >= 0; i--) {
      Projectile projectile = Level.projectiles[i];

      // Skip some updates if in slow motion for dramatic effect
      if (Game.effect.showSlowMotion && i % 2 == 0) continue;

      // Update projectile position with physics
      projectile.update(screenSize);

      // Check for projectile collision with target
      //if (projectile.collidesWith(Game.state.target)) {
      //  Engine.handleProjectileCollision(projectile, i);
      //  continue; // Skip the rest of the loop for this projectile
      //}

      // Remove projectile if it has bounced too many times or slowed down too much
      final projectileSpeed = sqrt(
        projectile.xVelocity * projectile.xVelocity +
            projectile.yVelocity * projectile.yVelocity,
      );

      if (projectileSpeed < 0.5 || projectile.bounceCount > 5) {
        Level.projectiles.removeAt(i);
      }
    }
  }

  void _updateParticles() {
    for (int i = Level.impactParticles.length - 1; i >= 0; i--) {
      // Update particle and remove if dead
      if (!Level.impactParticles[i].update()) {
        Level.impactParticles.removeAt(i);
      }
    }
  }

  void _press(KeyEvent event) {
    Player.handleKeyEvent(event);
    //Player.updatePlayerMovement();
  }

  @override
  Widget build(BuildContext context) {
    App.appContext = context;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;

    Game.camera.viewportWidth = screenWidth;
    Game.camera.viewportHeight = screenHeight;

    Level.size = Size(screenWidth, screenHeight);

    return Scaffold(
      body: Focus(
        autofocus: true,
        onKeyEvent: (FocusNode node, KeyEvent event) {
          _press(event);
          return KeyEventResult.ignored;
        },
        child: MouseRegion(
          onHover: Player.updateMousePosition,
          child: Container(
            key: _gameAreaKey,
            color:
                Game.effect.showSlowMotion
                    ? Colors.blueGrey[800] // Darker background for slow motion
                    : Colors.brown, // Normal background
            child: Stack(
              children: [
                // Background grid for visual reference (cached)
                //_buildCachedGrid(screenWidth, screenHeight),
                //Level.buildGrid(screenWidth, screenHeight, Game.camera),

                // Impact particles (combined for better performance)
                ...(Level.impactParticles.isNotEmpty
                    ? [Effect.particles(screenWidth, screenHeight, Game.camera)]
                    : []),

                // Projectile trails (combined for better performance)
                ...(Level.projectiles.isNotEmpty
                    ? [
                      Ball.buildCombinedTrails(
                        screenWidth,
                        screenHeight,
                        Game.camera,
                      ),
                    ]
                    : []),
                // Projectiles
                ...Level.projectiles.map(
                  (projectile) => Ball.buildBall(projectile, Game.camera),
                ),
                // Enemy rectangles
                ...Level.enemies.map((enemy) => Mob.build(enemy, Game.camera)),
                // Obstacles
                ...Level.obstacles.map(
                  (obstacle) => Obstacle.build(obstacle, Game.camera),
                ),
                // Target rectangle with physics info
                //Mob.target(Game.state, Game.camera),

                // Player-controlled rectangle
                Player.build(Game.camera),

                // Power meter and aiming line
                Weapon.build(
                  screenWidth,
                  screenHeight,
                  Player.mousePosition,
                  Game.camera,
                ),
                // HUD: Score and lives
                Panel.build(),
                // Game info panel with minimap
                // Slow motion overlay
                if (Game.effect.showSlowMotion)
                  Container(
                    width: screenWidth,
                    height: screenHeight,
                    color: Colors.blue.withAlpha(25),
                  ),

                Minimap.build(Game.camera, Game.effect.showSlowMotion),
                // Game over overlay
                if (Game.over) Game.buildGameOverOverlay(),
                if (Mob.remaining == 0) Game.buildGameOverOverlay(),
                Veil(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
