import 'dart:math';

import 'package:flutter/gestures.dart'; // Import for PointerScrollEvent
import 'package:flutter/material.dart';
import 'package:gunda/src/assetmanager.dart';
import 'package:gunda/src/ball.dart';
import 'package:gunda/src/camera.dart';
import 'package:gunda/src/drop.dart';
import 'package:gunda/src/effect.dart';
import 'package:gunda/src/engine.dart';
import 'package:gunda/src/game.dart';
import 'package:gunda/src/home.dart';
import 'package:gunda/src/level.dart';
import 'package:gunda/src/menu.dart';
import 'package:gunda/src/minimap.dart';
import 'package:gunda/src/mob.dart';
import 'package:gunda/src/mobile.dart';
import 'package:gunda/src/obstacle.dart';
import 'package:gunda/src/panel.dart';
import 'package:gunda/src/pause.dart';
import 'package:gunda/src/player.dart';
import 'package:gunda/src/shader.dart';
import 'package:gunda/src/sound.dart';
import 'package:gunda/src/weapon.dart';

class App extends StatefulWidget {
  static late BuildContext appContext;
  static bool home = true;
  static final SoundManager soundManager = SoundManager();
  static bool reset = false;
  static bool mobile = false;

  const App({super.key});

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
  bool _isLoading = true; // Add loading state flag

  Future<void> _initAudio() async {
    await App.soundManager.preloadSounds();
  }

  @override
  void initState() {
    super.initState();
    _initAudio();
    // Start loading assets
    AssetManager()
        .loadAllAssets()
        .then((_) {
          // When loading is complete, update state to rebuild UI
          if (mounted) {
            // Check if the widget is still in the tree
            setState(() {
              _isLoading = false; // Set loading to false
            });
          }
        })
        .catchError((error) {
          // Handle loading errors if necessary
          //print("Error loading assets: $error");
          if (mounted) {
            setState(() {
              _isLoading =
                  false; // Still stop loading on error, maybe show error message
            });
          }
        });

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

    Mobile.start();
  }

  @override
  void dispose() {
    Game.animationController.dispose();
    App.soundManager.dispose();
    //RawKeyboard.instance.removeListener(Player.handleKeyEvent);
    super.dispose();
  }

  void _updatePosition() {
    setState(() {
      if (App.reset) {
        Game.reset();
        App.home = true;
        App.reset = false;
      }
      if (Game.over) return;

      Game.update();
      Weapon.update();

      if (!Game.paused) {
        // Handle game state updates (like slow motion timer)
        //Game.update();

        // Update player movement based on input
        Player.updatePlayerMovement();

        // Update positions and handle collisions
        Engine.updatePlayerPhysics();

        // Make sure camera follows player
        Game.camera.follow(Player.body);

        // Update enemy positions and behaviors
        Mob.update();

        // Update projectiles and particles
        _updateProjectiles(Size(Game.gameWidth, Game.gameHeight));
        _updateParticles();

        // Update drops
        Drop.update();

        // Handle collisions
        Engine.checkCollisions(Size(Game.gameWidth, Game.gameHeight));
      }

      // Always call setState to trigger UI rebuilds,
      // ensuring changes like toggling pause are reflected.
      // Game logic updates are now handled conditionally above.
      // This call ensures the UI rebuilds based on the current state.
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
    Game.effect.update();
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

  void _mouseDown() {
    //debugPrint('HOHOHOH');
    Player.click();
  }

  void _mouseUp() {
    //debugPrint('HOHOHOH');
    Player.release();
  }

  @override
  Widget build(BuildContext context) {
    App.appContext = context;

    var screenWidth = MediaQuery.sizeOf(context).width;
    var screenHeight = MediaQuery.sizeOf(context).height;

    if (!App.mobile) {
      Game.camera.viewportWidth = screenWidth;
      Game.camera.viewportHeight = screenHeight;

      Level.size = Size(screenWidth, screenHeight);
    } else {
      screenWidth /= 2;
      Game.camera.viewportWidth = screenWidth;
      Game.camera.viewportHeight = screenHeight;

      Level.size = Size(screenWidth, screenHeight);
    }

    return Scaffold(
      // Restore the body
      body: Focus(
        autofocus: true,
        onKeyEvent: (FocusNode node, KeyEvent event) {
          _press(event);
          return KeyEventResult.ignored;
        },
        child: Listener(
          // Wrap with Listener to catch scroll events
          onPointerSignal: (pointerSignal) {
            if (pointerSignal is PointerScrollEvent) {
              // Use the vertical scroll delta for zooming
              // print("OKOKOK"); // Keep for debugging if needed
              Game.camera.zoom(pointerSignal.scrollDelta.dy);
              // No need to call setState explicitly here if _updatePosition already does
            }
          },
          child: MouseRegion(
            onHover: Player.updateMousePosition,
            child: Mobile.build(
              context,
              GestureDetector(
                onTapDown: (details) {
                  Player.tapDirection = details.localPosition;
                  if (App.mobile) {
                    Player.tapPosition(Player.tapDirection);
                  }
                  Player.click();
                },
                onTapUp: (details) {
                  Player.tapDirection = details.localPosition;
                  if (App.mobile) {
                    Player.tapPosition(Player.tapDirection);
                  }
                  _mouseUp();
                },

                child:
                    _isLoading // Check loading state
                        ? const Center(
                          child: CircularProgressIndicator(),
                        ) // Show loading indicator
                        : App.home
                        ? Home.build() // Show home screen if App.home is true
                        : Game.paused
                        ? Pause()
                        : Game.over
                        ? Menu()
                        : Container(
                          // Show game container if not loading and not home
                          key: _gameAreaKey,
                          color:
                              Game.effect.showSlowMotion
                                  ? Colors
                                      .blueGrey[800] // Darker background for slow motion
                                  : Colors.brown, // Normal background
                          child: Stack(
                            children: [
                              // Restore dynamic elements
                              ...Level.drops.map(
                                (drop) => Drop.build(drop, Game.camera),
                              ),
                              ...(Level.impactParticles.isNotEmpty
                                  ? [
                                    Effect.particles(
                                      screenWidth,
                                      screenHeight,
                                      Game.camera,
                                    ),
                                  ]
                                  : []),
                              ...(Level.projectiles.isNotEmpty
                                  ? [
                                    Ball.buildCombinedTrails(
                                      screenWidth,
                                      screenHeight,
                                      Game.camera,
                                    ),
                                  ]
                                  : []),
                              ...Level.projectiles.map(
                                (projectile) =>
                                    Ball.buildBall(projectile, Game.camera),
                              ),
                              ...Level.enemies.map(
                                (enemy) => Mob.build(enemy, Game.camera),
                              ),
                              ...Level.obstacles.map(
                                (obstacle) =>
                                    Obstacle.build(obstacle, Game.camera),
                              ),
                              Player.build(Game.camera), // Keep Player
                              Weapon.build(
                                // Keep Weapon
                                screenWidth,
                                screenHeight,
                                Player.mousePosition,
                                Game.camera,
                              ),
                              Panel.build(), // Keep Panel
                              if (Game.effect.showSlowMotion)
                                Container(
                                  width: screenWidth,
                                  height: screenHeight,
                                  color: Colors.blue.withAlpha(25),
                                ),
                              Minimap.build(
                                // Keep Minimap
                                Game.camera,
                                Game.effect.showSlowMotion,
                              ),
                              // Game over overlay
                              //if (Game.paused) Pause(),
                              //if (Game.over) Menu.buildGameOverOverlay(),
                              //if (Level.remaining == 0) Game.buildGameOverOverlay(),
                              DirtyPixel(), // Keep Shader
                            ],
                          ),
                        ),
              ), // Closes GestureDetector
            ), // Closes Mobile.build
          ), // Closes Listener
        ), // Closes Focus
        //  ),
      ),
    );
  }
}
