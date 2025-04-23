import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gunda/src/app.dart';
import 'package:gunda/src/body.dart';
import 'package:gunda/src/camera.dart';
import 'package:gunda/src/effect.dart';
import 'package:gunda/src/level.dart';
import 'package:gunda/src/player.dart';
import 'package:gunda/src/weapon.dart';

class Game {
  static Player player = Player();
  static final Random random = Random();
  static final Effect effect = Effect();
  static Camera camera = Camera(viewportWidth: 0, viewportHeight: 0);
  static bool paused = false;
  static bool over = false;
  static bool next = false;
  static bool start = true;
  static int score = 0;
  static const double gameWidth = 2400;
  static const double gameHeight = 2400;
  static late AnimationController animationController;
  static int level = 0;

  static void reset() {
    //isGameOver = false;
    //lives = Player.maxHearts;
    Player.lives = 3;

    //Level.projectiles.clear();
    //Level.impactParticles.clear();
    //Level.remaining = Level.allMob - Level.maxMob;

    Weapon.power = Weapon.minPower;
    Weapon.isChargingShot = false;

    // Initialize player at center of game world
    //App.home = true;

    Game.over = false;
    Game.score = 0;

    Player.body = Body(
      x: Game.gameWidth / 2 - Player.width / 2,
      y: Game.gameHeight / 2 - Player.height / 2,
      xVelocity: 0,
      yVelocity: 0,
      width: Player.width,
      height: Player.height,
      color: Colors.blue,
      mass: Player.playerMass,
    );

    Game.level = 0;
    Level.enter();

    // player.load();
  }

  static void nextLevel() {
    Player.lives = 3;

    Weapon.power = Weapon.minPower;
    Weapon.isChargingShot = false;

    //Level.projectiles.clear();
    //Level.impactParticles.clear();
    //Level.remaining = Level.allMob - Level.maxMob;

    // Initialize player at center of game world
    Player.body = Body(
      x: Game.gameWidth / 2 - Player.width / 2,
      y: Game.gameHeight / 2 - Player.height / 2,
      xVelocity: 0,
      yVelocity: 0,
      width: Player.width,
      height: Player.height,
      color: Colors.blue,
      mass: Player.playerMass,
    );

    Game.over = false;
    Game.score = 0;
    Game.level++;

    Level.enter();
  }

  static void update() {
    // Handle power level updates for charging shot
    if (Weapon.isChargingShot) {
      Weapon.updateChargingPower();
    }

    // Decrement slow motion timer
    if (Game.effect.showSlowMotion) {
      Game.effect.slowMotionTimer -= 1;
      if (Game.effect.slowMotionTimer <= 0) {
        Game.effect.showSlowMotion = false;
      }
    }
  }

  static Widget buildGameOverOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              Level.remaining > 0 ? 'GAME OVER' : 'VICTORY',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            //Text(
            //  'Final Score: ${Game.score}',
            //  style: const TextStyle(color: Colors.white, fontSize: 24),
            //),
            const SizedBox(height: 30),
            Text(
              Level.remaining > 0
                  ? 'ENTER TO RESTART'
                  : Player.lives > 0
                  ? Game.level < Level.zones.length - 1
                      ? 'ENTER NEXT LEVEL'
                      : 'ENTER TO RESTART'
                  : 'ENTER TO RESTART',
              //: 'ENTER NEXT LEVEL',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
