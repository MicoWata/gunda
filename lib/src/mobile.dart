import 'package:flutter/foundation.dart' as foundation; // Import kIsWeb
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
    if (foundation.defaultTargetPlatform == TargetPlatform.android ||
        foundation.defaultTargetPlatform == TargetPlatform.iOS) {
      App.mobile = true;
    }
    if (foundation.kIsWeb &&
        (foundation.defaultTargetPlatform == TargetPlatform.android ||
            foundation.defaultTargetPlatform == TargetPlatform.iOS)) {
      App.mobile = true;
    }
    if (foundation.kIsWeb ||
        foundation.defaultTargetPlatform == TargetPlatform.windows ||
        foundation.defaultTargetPlatform == TargetPlatform.linux ||
        foundation.defaultTargetPlatform == TargetPlatform.macOS) {
      App.mobile = false;
    }
  }

  static Widget left(double width) {
    // Visual size for the buttons
    const double buttonVisualSize = 60.0;

    return SizedBox(
      width: width,
      height: Game.camera.viewportHeight,
      child: Container(
        //color: Colors.black54, // Make it semi-transparent
        child:
            Game.paused
                ? Container()
                : Center(
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
        decoration: BoxDecoration(
          color: Colors.deepPurple, // A slightly richer color
          borderRadius: BorderRadius.circular(size * 0.2), // Rounded corners
          border: Border.all(
            color: Colors.black.withOpacity(0.7), // Darker border
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(2, 2), // Shadow for a raised effect
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.7),
      ),
    );
  }

  static Widget middle(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.deepPurple, // A slightly richer color
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(2, 2), // Shadow for a raised effect
          ),
        ],
      ),
      child: SizedBox(
        width: Game.camera.viewportWidth,
        height: Game.camera.viewportHeight * 0.9,
        child: child,
      ),
    );
  }

  static Widget action(IconData icon, Actions action, double size) {
    final double buttonSize = size * 0.7;

    return GestureDetector(
      onTapDown:
          (_) => switch (action) {
            Actions.dash => Player.dash(),
            Actions.weapon => Player.changeWeapon(),
            Actions.pause => Game.paused = true,
          },
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: Colors.deepPurple, // A slightly richer color
          borderRadius: BorderRadius.circular(
            buttonSize * 0.2,
          ), // Rounded corners
          border: Border.all(
            color: Colors.black.withOpacity(0.7), // Darker border
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(2, 2), // Shadow for a raised effect
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white.withOpacity(0.9), // Slightly muted white icon
          size: buttonSize * 0.6, // Adjust icon size relative to button
        ),
      ),
    );
  }

  static Widget right(double width) {
    return SizedBox(
      width: width,
      height: Game.camera.viewportHeight,
      child: Container(
        //color: Colors.black54,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //SizedBox(width: width * 0.1),
            Game.paused
                ? Container()
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    action(Icons.change_circle, Actions.weapon, width),
                    SizedBox(height: 20),
                    action(Icons.directions_run, Actions.dash, width),
                    SizedBox(height: 20),
                    action(Icons.pause, Actions.pause, width),
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

    double width = (screenWidth / 2) / 2;

    return Container(
      color: Colors.purple.shade900,
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
