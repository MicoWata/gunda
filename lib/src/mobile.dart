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
    const double moveImpulse =
        Player.acceleration * 15; // Adjust impulse strength as needed

    return SizedBox(
      width: width,
      height: Game.camera.viewportHeight,
      child: Container(
        color: Colors.blueGrey, // Make it semi-transparent
        child: Center(
          child: SizedBox(
            //width: buttonSize * 3,
            //height: buttonSize * 3,
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap:
                  true, // Important to prevent GridView from expanding infinitely
              physics:
                  const NeverScrollableScrollPhysics(), // Disable scrolling
              children: [
                Container(), // Top-left empty
                Container(
                  color: Colors.purple,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_upward),

                    highlightColor: Colors.blue,
                    //hoverColor: Colors.blueAccent,
                    //iconSize: buttonSize,
                    color: Colors.white,
                    onPressed: () => Player.moveMobile(Directions.up),
                  ),
                ),
                Container(), // Top-right empty
                Container(
                  color: Colors.purple,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    highlightColor: Colors.blue,
                    //iconSize: buttonSize * 0.8,
                    color: Colors.white,
                    onPressed: () => Player.moveMobile(Directions.left),
                  ),
                ),
                Container(), // Middle empty (or maybe a dash button later?)
                Container(
                  color: Colors.purple,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    highlightColor: Colors.blue,
                    //iconSize: buttonSize * 0.8,
                    color: Colors.white,
                    onPressed: () => Player.moveMobile(Directions.right),
                  ),
                ),
                Container(), // Bottom-left empty
                Container(
                  color: Colors.purple,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_downward),
                    //iconSize: buttonSize * 0.8,
                    color: Colors.white,
                    highlightColor: Colors.blue,
                    onPressed: () => Player.moveMobile(Directions.down),
                  ),
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
      child:
          App.mobile
              ? Row(children: [left(width), middle(child), right(width)])
              : child,
    );
  }
}
