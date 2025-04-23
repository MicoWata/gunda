import 'package:flutter/material.dart';
import 'package:gunda/src/body.dart';
import 'package:gunda/src/camera.dart';
import 'package:gunda/src/level.dart';
import 'package:gunda/src/player.dart';

enum Drops { heal }

class Drop {
  Drops kind = Drops.heal;
  bool used = false;
  Body body;

  Drop({required this.kind, required this.body, this.used = false});

  static void update() {
    for (Drop drop in Level.drops) {
      if (!drop.used && drop.body.collidesWith(Player.body)) {
        Player.lives++;
        drop.used = true;
      }
    }
  }

  static Widget build(Drop drop, Camera camera) {
    return !drop.used
        ? Positioned(
          left: drop.body.x - camera.x,
          top: drop.body.y - camera.y,
          child: Container(
            width: drop.body.width,
            height: drop.body.height,
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 4,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '+',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                textHeightBehavior: TextHeightBehavior(
                  applyHeightToFirstAscent: false,
                ),
              ),
            ),
          ),
        )
        : Container();
  }

  /// Convert Drop object to a JSON map
  Map<String, dynamic> toJson() => {
        'kind': kind.name,
        'used': used,
        'body': body.toJson(),
      };

  /// Create Drop object from a JSON map
  factory Drop.fromJson(Map<String, dynamic> json) => Drop(
        kind: Drops.values.firstWhere((e) => e.name == (json['kind'] as String)),
        body: Body.fromJson(json['body'] as Map<String, dynamic>),
        used: json['used'] as bool,
      );
}
