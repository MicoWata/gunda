import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:gunda/src/app.dart';
import 'package:gunda/src/game.dart';

class Mobile {
  double screenWidth = 0;
  double screenHeight = 0;

  static void start() {
    if (Platform.isAndroid || Platform.isIOS) {
      App.mobile = true;
    }
  }

  static Widget left(double width) {
    //let's add four buttons here to move the player in either direction AI
    return SizedBox(
      width: width,
      height: Game.camera.viewportHeight,
      child: Container(color: Colors.blueGrey),
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
