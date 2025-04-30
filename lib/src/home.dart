import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gunda/src/app.dart';
import 'package:gunda/src/game.dart';
import 'package:gunda/src/save.dart';

class Home {
  static bool skip = false;
  static bool challenge = false;

  static Widget start() {
    return ElevatedButton(
      onPressed: () async {
        challenge = true;
        //App.home = false;
        //Game.paused = false;
        //if (Game.playSong) {
        //  App.soundManager.playSong('music/song2.wav');
        //}
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

  static Widget welcome() {
    return Center(
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
          const SizedBox(height: 30),
          start(),
          const SizedBox(height: 20),
          load(),
          const SizedBox(height: 20),
          close(),
        ],
      ),
    );
  }

  static Widget choice(Challenge level) {
    String text = "Baby";

    if (level == Challenge.normie) {
      text = "Normie";
    } else if (level == Challenge.boss) {
      text = "Boss";
    }

    return ElevatedButton(
      onPressed: () async {
        App.home = false;
        Game.paused = false;
        Game.challenge = level;
        challenge = false;

        if (Game.playSong) {
          App.soundManager.playSong('music/song2.wav');
        }
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      ),
      child: Text(text, style: TextStyle(fontSize: 20)),
    );
  }

  static Widget difficulty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'CHALLENGE',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          choice(Challenge.baby),
          const SizedBox(height: 20),
          choice(Challenge.normie),
          const SizedBox(height: 20),
          choice(Challenge.boss),
        ],
      ),
    );
  }

  static Widget build() {
    return Container(
      color: Colors.deepPurple,
      child: challenge ? difficulty() : welcome(),
    );
  }
}
