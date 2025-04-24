import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gunda/src/app.dart';
import 'package:gunda/src/game.dart';
import 'package:gunda/src/save.dart';

class Home {
  static bool skip = false;

  static Widget start() {
    return ElevatedButton(
      onPressed: () async {
        App.home = false;
        Game.paused = false;
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      ),
      child: const Text('New Game', style: TextStyle(fontSize: 20)),
    );
  }

  static Widget load() {
    return ElevatedButton(
      onPressed: () {
        Save.loadGame();
        App.home = false;
        Game.paused = false;
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      ),
      child: const Text('Continue', style: TextStyle(fontSize: 20)),
    );
  }

  static Widget close() {
    return ElevatedButton(
      onPressed: () {
        SystemNavigator.pop();
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      ),
      child: const Text('Exit', style: TextStyle(fontSize: 20)),
    );
  }

  static Widget build() {
    return Container(
      color: Colors.teal,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'GUNDA',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 50),
            start(),
            const SizedBox(height: 40),
            load(),
            const SizedBox(height: 40),
            close(),
          ],
        ),
      ),
    );
  }
}
