import 'dart:io' show Platform;

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:gunda/src/app.dart';
import 'package:gunda/src/game.dart';
import 'package:gunda/src/player.dart'; // Import Player

class Mobile {
  double screenWidth = 0;
  double screenHeight = 0;

  static void start() {
    if (Platform.isAndroid || Platform.isIOS) {
      App.mobile = true;
    }
  }

  static Widget left(double width) {
    // Add buttons for player movement
    const double buttonSize = 50.0;
    const double moveImpulse = Player.acceleration * 15; // Adjust impulse strength as needed

    return SizedBox(
      width: width,
      height: Game.camera.viewportHeight,
      child: Container(
        color: Colors.blueGrey.withOpacity(0.5), // Make it semi-transparent
        child: Center(
          child: SizedBox(
            width: buttonSize * 3,
            height: buttonSize * 3,
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true, // Important to prevent GridView from expanding infinitely
              physics: const NeverScrollableScrollPhysics(), // Disable scrolling
              children: [
                Container(), // Top-left empty
                IconButton(
                  icon: const Icon(Icons.arrow_upward),
                  iconSize: buttonSize * 0.8,
                  color: Colors.white,
                  onPressed: () => Player.body.yVelocity -= moveImpulse,
                ),
                Container(), // Top-right empty
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  iconSize: buttonSize * 0.8,
                  color: Colors.white,
                  onPressed: () => Player.body.xVelocity -= moveImpulse,
                ),
                Container(), // Middle empty (or maybe a dash button later?)
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  iconSize: buttonSize * 0.8,
                  color: Colors.white,
                  onPressed: () => Player.body.xVelocity += moveImpulse,
                ),
                Container(), // Bottom-left empty
                IconButton(
                  icon: const Icon(Icons.arrow_downward),
                  iconSize: buttonSize * 0.8,
                  color: Colors.white,
                  onPressed: () => Player.body.yVelocity += moveImpulse,
                ),
                Container(), // Bottom-right empty
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget middle(Widget child) {
    return SizedBox(
      width: Game.camera.viewportWidth,
      height: Game.camera.viewportHeight,
      child: child,
    );
  }

  static Widget right(double width) {
    return SizedBox(
      width: width,
      height: Game.camera.viewportHeight,
      child: Container(color: Colors.blueGrey),
    );
  }

  static void press(int button) {
    //if (event is KeyDownEvent) {
    //  _pressedKeys.add(event.logicalKey);
    //
    //  if (event.logicalKey == LogicalKeyboardKey.space) {
    //    dash();
    //  }
    //  if (event.logicalKey == LogicalKeyboardKey.keyE) {
    //    changeWeapon();
    //  }
    //  if (event.logicalKey == LogicalKeyboardKey.escape) {
    //    Game.paused = !Game.paused;
    //  }
    //  if (event.logicalKey == LogicalKeyboardKey.keyK) {
    //    kill();
    //  }
    //  if (event.logicalKey == LogicalKeyboardKey.keyP) {
    //    Save.saveGame();
    //  }
    //  if (event.logicalKey == LogicalKeyboardKey.enter) {
    //    enter();
    //  }
    //  //if (event.logicalKey == LogicalKeyboardKey.space) {
    //  //  attack();
    //  //}
    //} else if (event is KeyUpEvent) {
    //  //if (event.logicalKey == LogicalKeyboardKey.space &&
    //  //    Weapon.isChargingShot) {
    //  //  Weapon.releaseShot(worldMousePosition);
    //  //}
    //
    //  _pressedKeys.remove(event.logicalKey);
    //}
  }

  static Widget build(BuildContext context, Widget child) {
    var screenWidth = MediaQuery.sizeOf(context).width;
    var screenHeight = MediaQuery.sizeOf(context).height;

    double width = (screenWidth - screenHeight) / 2;

    return Container(
      color: Colors.purple,
      child: Row(children: [left(width), middle(child), right(width)]),
    );
  }
}
