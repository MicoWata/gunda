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
  static bool paused = true;
  static bool over = false;
  static bool next = false;
  static bool start = true;
  static bool playSong = true;
  static int score = 0;
  static const double gameWidth = 2400;
  static const double gameHeight = 2400;
  static late AnimationController animationController;
  static int level = 0;
  static int frame = 0;

  static void reset() {
    //if (App.mobile) {
    //  gameWidth * 2;
    //  gameHeight * 2;
    //}
    //isGameOver = false;
    //lives = Player.maxHearts;
    Player.lives = 3;
    Weapon.kind = Weapons.bazooka;

    //Level.projectiles.clear();
    //Level.impactParticles.clear();
    //Level.remaining = Level.allMob - Level.maxMob;

    Weapon.power = Weapon.minPower;
    Weapon.isChargingShot = false;

    //App.home = true;

    Game.paused = true;
    Game.over = false;
    Game.score = 0;

    Player.body = Body(
      x: Game.gameWidth / 2 - Player.width / 2,
      y: Game.gameHeight / 2 - Player.height / 2,
      xVelocity: 0,
      yVelocity: 0,
      width: App.mobile ? Player.width : Player.width,
      height: App.mobile ? Player.height : Player.height,
      color: Colors.blue,
      mass: Player.playerMass,
    );

    Game.level = 0;
    Level.enter();

    Game.camera.zoomOut();
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
    frame++;
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
}
