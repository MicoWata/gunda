import 'dart:math' show Random, sqrt, pow;
import 'package:flutter/material.dart';
import 'package:gunda/src/ball.dart';
import 'package:gunda/src/body.dart';
import 'package:gunda/src/effect.dart';
import 'package:gunda/src/game.dart';
import 'package:gunda/src/mob.dart';
import 'package:gunda/src/obstacle.dart';
import 'package:gunda/src/player.dart';
import 'package:gunda/src/weapon.dart';

class GameState {
  bool isGameOver = false;
  int lives = Player.maxHearts;
  int score = 0;
  int kills = 0;
  //int goal = 3;

  // Player rectangle
  late Body player;

  // Enemy rectangles
  final List<Enemy> enemies = [];

  // Enemy shooting
  final List<bool> enemyCanShoot = [];
  final List<int> enemyShootCooldowns = [];
  final int defaultEnemyShootCooldown = 2000; // milliseconds

  // Projectiles list
  final List<Projectile> projectiles = [];

  // Impact particles system
  final List<ImpactParticle> impactParticles = [];
  
  // Obstacles in the game
  final List<Obstacle> obstacles = [];

  final Random _random = Random();

  late AnimationController animationController;

  /// Initialize enemies at random positions
  void _initializeEnemies() {
    double maxWidth = Game.gameWidth - Mob.size.width;
    double maxHeight = Game.gameHeight - Mob.size.height;

    // Clear existing enemies
    enemies.clear();
    enemyCanShoot.clear();
    enemyShootCooldowns.clear();

    // Create new enemies
    for (int i = 0; i < Mob.max; i++) {
      // Generate random color shade
      final hue = _random.nextInt(360);
      final color = HSVColor.fromAHSV(1.0, hue.toDouble(), 0.7, 0.9).toColor();

      // Create enemy with random position but avoid player's initial position
      double enemyX, enemyY;
      do {
        enemyX = _random.nextDouble() * maxWidth;
        enemyY = _random.nextDouble() * maxHeight;
      } while (_isNearPlayer(
        enemyX,
        enemyY,
        300,
      )); // Minimum distance of 300 from player

      Enemy enemy = Enemy(
        body: Body(
          x: enemyX,
          y: enemyY,
          xVelocity: _random.nextDouble() * 2 - 1, // Random initial velocity
          yVelocity: _random.nextDouble() * 2 - 1, // Random initial velocity
          width: Mob.size.width * 0.8, // Slightly smaller than target
          height: Mob.size.height * 0.8, // Slightly smaller than target
          color: color,
          mass: Mob.mass, // Slightly lighter than target
        ),
      );

      enemies.add(enemy);
      enemyCanShoot.add(true); // Each enemy can shoot initially
      enemyShootCooldowns.add(
        defaultEnemyShootCooldown + _random.nextInt(1000),
      ); // Stagger cooldowns
    }
  }

  /// Check if a position is too close to the player's starting position
  bool _isNearPlayer(double x, double y, double minDistance) {
    if (!player.x.isNaN) {
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

  /// Initialize obstacles in the game world
  void _initializeObstacles() {
    obstacles.clear();
    
    // Create border walls around the game area
    // Left wall
    obstacles.add(ObstacleFactory.createWall(
      x: -20,
      y: -20,
      width: 20,
      height: Game.gameHeight + 40,
    ));
    
    // Right wall
    obstacles.add(ObstacleFactory.createWall(
      x: Game.gameWidth,
      y: -20,
      width: 20,
      height: Game.gameHeight + 40,
    ));
    
    // Top wall
    obstacles.add(ObstacleFactory.createWall(
      x: -20,
      y: -20,
      width: Game.gameWidth + 40,
      height: 20,
    ));
    
    // Bottom wall
    obstacles.add(ObstacleFactory.createWall(
      x: -20,
      y: Game.gameHeight,
      width: Game.gameWidth + 40,
      height: 20,
    ));
    
    // Add some obstacles inside the game area
    // Central block
    obstacles.add(ObstacleFactory.createMetalBarrier(
      x: Game.gameWidth / 2 - 100,
      y: Game.gameHeight / 2 - 100,
      width: 200,
      height: 200,
    ));
    
    // Random rocks
    for (int i = 0; i < 15; i++) {
      double rockSize = 30 + _random.nextDouble() * 70;
      double rockX = _random.nextDouble() * (Game.gameWidth - rockSize);
      double rockY = _random.nextDouble() * (Game.gameHeight - rockSize);
      
      // Ensure rocks aren't placed near the player starting position
      if (!_isNearPlayer(rockX, rockY, 350)) {
        obstacles.add(ObstacleFactory.createRock(
          x: rockX,
          y: rockY,
          size: rockSize,
        ));
      }
    }
  }

  /// Reset the game to initial state
  void resetGame() {
    isGameOver = false;
    lives = Player.maxHearts;
    score = 0;
    projectiles.clear();
    impactParticles.clear();
    Weapon.power = Weapon.minPower;
    Weapon.isChargingShot = false;
    Mob.remaining = Mob.count;

    // Initialize player at center of game world
    player = Body(
      x: Game.gameWidth / 2 - Player.width / 2,
      y: Game.gameHeight / 2 - Player.height / 2,
      xVelocity: 0,
      yVelocity: 0,
      width: Player.width,
      height: Player.height,
      color: Colors.blue,
      mass: Player.playerMass,
    );

    _initializeEnemies();
    _initializeObstacles();
  }
}
