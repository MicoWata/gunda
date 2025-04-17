import 'dart:math';

import 'package:flutter/material.dart';
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
  static int score = 0;
  static const double gameWidth = 2400;
  static const double gameHeight = 2400;
  static late AnimationController animationController;
  static int level = 0;

  static void reset() {
    //isGameOver = false;
    //lives = Player.maxHearts;
    Player.lives = 3;
    Game.over = false;
    Game.score = 0;
    Level.projectiles.clear();
    Level.impactParticles.clear();
    Weapon.power = Weapon.minPower;
    Weapon.isChargingShot = false;
    Level.remaining = Level.allMob - Level.maxMob;

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

    Level.enter();
  }

  static void nextLevel() {
    Player.lives = 3;
    Game.over = false;
    Game.score = 0;
    Level.projectiles.clear();
    Level.impactParticles.clear();
    Weapon.power = Weapon.minPower;
    Weapon.isChargingShot = false;

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

  static Widget button() {
    var text = 'Play Again';

    void press() {
      if (Level.remaining > 0) {
        Player.body.width = 200;
        Game.reset();
        Game.animationController.repeat();
      } else if (Game.level < Level.zones.length) {
        Game.nextLevel();
      }
    }

    return ElevatedButton(
      onPressed: press,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      ),
      child: Text(text, style: TextStyle(fontSize: 20)),
    );
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
            Text(
              'Final Score: ${Game.score}',
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 30),
            button(),
          ],
        ),
      ),
    );
  }
}
