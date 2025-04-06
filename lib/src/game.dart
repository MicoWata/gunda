import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gunda/src/camera.dart';
import 'package:gunda/src/effect.dart';
import 'package:gunda/src/mob.dart';
import 'package:gunda/src/player.dart';
import 'package:gunda/src/state.dart';
import 'package:gunda/src/weapon.dart';

class Game {
  // Cached widgets for better performance
  static Player player = Player();
  static final Random random = Random();
  static final GameState state = GameState();
  static final Effect effect = Effect();
  static Camera camera = Camera(viewportWidth: 0, viewportHeight: 0);
  static bool paused = false;
  static const double gameWidth = 2400;
  static const double gameHeight = 2400;

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

  static bool over() {
    if (Mob.remaining < 1) {
      return true;
    }
    return false;
  }

  static Widget buildGameOverOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              Mob.remaining > 0 ? 'GAME OVER' : 'VICTORY',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Final Score: ${Game.state.score}',
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                //setState(() {
                Game.state.resetGame();
                Game.state.animationController.repeat();
                //});
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
              child: const Text('Play Again', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
