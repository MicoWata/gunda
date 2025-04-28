import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:gunda/src/app.dart';
import 'package:gunda/src/game.dart';
import 'package:gunda/src/player.dart'; // Import Player

enum Actions { dash, weapon, pause }

class Mobile {
  // Set to track currently pressed mobile direction buttons
  static final Set<Directions> pressedDirections = {};

  double screenWidth = 0;
  double screenHeight = 0;

  static void start() {
    if (Platform.isAndroid || Platform.isIOS) {
      App.mobile = true;
    }
  }

  static Widget left(double width) {
    // Visual size for the buttons
    const double buttonVisualSize = 60.0;

    return SizedBox(
      width: width,
      height: Game.camera.viewportHeight,
      child: Container(
        color: Colors.blueGrey, // Make it semi-transparent
        child: Center(
          child: Row(
            children: [
              SizedBox(width: width * 0.25),
              SizedBox(
                width: width * 0.7,
                //height: buttonSize * 3,
                child: GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap:
                      true, // Important to prevent GridView from expanding infinitely
                  physics:
                      const NeverScrollableScrollPhysics(), // Disable scrolling
                  children: [
                    Container(), // Top-left empty
                    _buildMoveButton(
                      Icons.arrow_upward,
                      Directions.up,
                      buttonVisualSize,
                    ),
                    Container(), // Top-right empty
                    _buildMoveButton(
                      Icons.arrow_back,
                      Directions.left,
                      buttonVisualSize,
                    ),
                    Container(), // Middle empty
                    _buildMoveButton(
                      Icons.arrow_forward,
                      Directions.right,
                      buttonVisualSize,
                    ),
                    Container(), // Bottom-left empty
                    _buildMoveButton(
                      Icons.arrow_downward,
                      Directions.down,
                      buttonVisualSize,
                    ),
                    Container(), // Bottom-right empty
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void tap(Directions direction) {
    pressedDirections.add(direction);
  }

  // Helper widget to build a movement button with GestureDetector
  static Widget _buildMoveButton(
    IconData icon,
    Directions direction,
    double size,
  ) {
    return GestureDetector(
      onTapDown: (_) => tap(direction),
      onTapUp: (_) => pressedDirections.remove(direction),
      onTapCancel: () => pressedDirections.remove(direction),
      child: Container(
        width: size,
        height: size,
        color: Colors.purple, // Button background
        child: Icon(icon, color: Colors.white, size: size * 0.7),
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

  static Widget action(IconData icon, Actions action) {
    double size = 85;

    return GestureDetector(
      onTapDown:
          (_) => switch (action) {
            Actions.dash => Player.dash(),
            Actions.weapon => Player.changeWeapon(),
            Actions.pause => Game.paused = true,
          },
      //onTapUp: (_) => pressedDirections.remove(direction),
      //onTapCancel: () => pressedDirections.remove(direction),
      child: Container(
        width: size,
        height: size,
        color: Colors.purple, // Button background
        child: Icon(icon, color: Colors.white, size: size * 0.7),
      ),
    );
  }

  static Widget right(double width) {
    return SizedBox(
      width: width,
      height: Game.camera.viewportHeight,
      child: Container(
        color: Colors.blueGrey,
        child: Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                action(Icons.change_circle, Actions.weapon),
                SizedBox(height: 20, width: width * 0.9),
                action(Icons.directions_run, Actions.dash),
                SizedBox(height: 20),
                action(Icons.pause, Actions.pause),
              ],
            ),
            //SizedBox(width: width * 0.1),
          ],
        ),
      ),
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
              ? Row(
                children: [
                  left(width * 1.5),
                  middle(child),
                  right(width * 0.5),
                ],
              )
              : child,
    );
  }
}
