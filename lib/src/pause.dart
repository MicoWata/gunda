import 'package:flutter/material.dart';
import 'package:gunda/src/game.dart';
import 'package:gunda/src/mob.dart';

class Pause {
  static Widget buildGameOverOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "PAUSE",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Remaining mobs: ${Mob.remaining}',
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                //setState(() {
                Game.paused = false;
                Game.state.animationController.repeat();
                //});
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
              child: const Text('Continue', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
