import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gunda/src/body.dart';
import 'package:gunda/src/camera.dart';
import 'package:gunda/src/game.dart';
import 'package:gunda/src/level.dart';
import 'package:gunda/src/app.dart';
import 'package:gunda/src/mob.dart';
import 'package:gunda/src/save.dart';
import 'package:gunda/src/sound.dart';
import 'package:gunda/src/weapon.dart';
import 'package:gunda/src/assetmanager.dart';
import 'package:gunda/src/spriteanimation.dart';

class Player {
  static const double width = 80;
  static const double height = 100;

  static int maxHearts = 3;
  static int lives = 3;
  static int score = 0;
  static Body body = Body(x: 0, y: 0, width: 0, height: 0, color: Colors.red);

  static const double acceleration = 0.8;
  static const double maxSpeed = 64.0;
  static const double friction = 0.9;
  static const double minMovementThreshold = 0.1;

  static final Set<LogicalKeyboardKey> _pressedKeys = {};

  static Offset mousePosition = Offset.zero;
  static Offset worldMousePosition = Offset.zero;

  static const double playerMass = 10.0;

  late SpriteAnimation idleAnimation;

  // Future<void> load() async {
  //   final frames = await AssetManager().loadPlayerIdle();
  //   if (frames == null) {
  //     throw Exception('player_idle sprite sequence not loaded!');
  //   }

  //   idleAnimation = SpriteAnimation(frames, 0.1);
  // }

  void update(double delta) {
    idleAnimation.update(delta);
  }

  void paint(Canvas canvas) {
    final frame = idleAnimation.currentFrame;
    canvas.drawImage(frame, Offset(body.x, body.y), Paint());
  }

  static void updateMousePosition(PointerEvent event) {
    //setState(() {
    Player.mousePosition = event.position;

    // Convert screen coordinates to world coordinates by adding camera position
    Player.worldMousePosition = Offset(
      Game.camera.x + event.position.dx,
      Game.camera.y + event.position.dy,
    );
    //});
  }

  static void kill() {
    for (Enemy mob in Level.enemies) {
      if (mob.hp > 0) {
        mob.hurt();
      }
    }
  }

  static void dash() {
    double power = 50;
    final recoilForce = power * 24 / Player.playerMass;

    // Get current velocity
    final vx = Player.body.xVelocity;
    final vy = Player.body.yVelocity;

    final speed = sqrt(vx * vx + vy * vy);

    // Don't dash if the player isn't moving
    if (speed == 0) return;

    // Normalize the velocity vector
    final normalizedDx = vx / speed;
    final normalizedDy = vy / speed;

    // Apply dash impulse in the direction of movement
    Player.body.applyImpulse(
      normalizedDx * recoilForce * 2,
      normalizedDy * recoilForce * 2,
    );
    //   Offset mouse = worldMousePosition;
    //   double power = 50;

    //   final recoilForce = power * 24 / Player.playerMass;

    //   // Calculate direction from player to mouse
    //   final playerCenterX = Player.body.centerX;
    //   final playerCenterY = Player.body.centerY;

    //   // Calculate vector from player to world mouse position
    //   final dx = mouse.dx - playerCenterX;
    //   final dy = mouse.dy - playerCenterY;

    //   // Normalize the vector
    //   final distance = sqrt(dx * dx + dy * dy);
    //   final normalizedDx = dx / distance;
    //   final normalizedDy = dy / distance;

    //   Player.body.applyImpulse(
    //     normalizedDx * recoilForce * 2,
    //     normalizedDy * recoilForce * 2,
    //   );
  }

  static void enter() {
    if (Game.over) {
      if (Level.remaining > 0) {
        Game.reset();
        Game.animationController.repeat();
      } else if (Game.level < Level.zones.length - 1) {
        Game.nextLevel();
        Game.animationController.repeat();
      } else {
        Game.reset();
        Game.animationController.repeat();
      }
    }
  }

  static void click() {
    attack();
  }

  static void release() {
    if (Weapon.isChargingShot) {
      Weapon.releaseShot(worldMousePosition);
    }
  }

  static void attack() {
    if (Weapon.kind == Weapons.pistol ||
        Weapon.kind == Weapons.shotgun ||
        Weapon.kind == Weapons.bazooka) {
      shoot();
    } else {
      hit();
    }
  }

  static Future<void> shoot() async {
    //await Sound.player.play(AssetSource('sounds/shoot.wav'));

    //App.soundManager.playSoundNew('sounds/pew1.mp3');

    if (!Game.over && !Game.paused) {
      if (Weapon.kind == Weapons.pistol && !Weapon.isChargingShot) {
        Weapon.startChargingShot();
      } else if (Weapon.kind == Weapons.shotgun) {
        Weapon.spreadShot(worldMousePosition);
      } else if (Weapon.kind == Weapons.bazooka) {
        Weapon.explosiveShot(worldMousePosition);
      }
    }
  }

  static void hit() {
    if (!Game.over && !Game.paused) {
      Weapon.slice();
    }
  }

  static void changeWeapon() {
    switch (Weapon.kind) {
      case Weapons.sword:
        Weapon.kind = Weapons.pistol;
      case Weapons.pistol:
        Weapon.kind = Weapons.shotgun;
      case Weapons.shotgun:
        Weapon.kind = Weapons.bazooka;
      case Weapons.bazooka:
        Weapon.kind = Weapons.sword;
    }
  }

  static void handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      _pressedKeys.add(event.logicalKey);

      if (event.logicalKey == LogicalKeyboardKey.space) {
        dash();
      }
      if (event.logicalKey == LogicalKeyboardKey.keyE) {
        changeWeapon();
      }
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        Game.paused = !Game.paused;
      }
      if (event.logicalKey == LogicalKeyboardKey.keyK) {
        kill();
      }
      if (event.logicalKey == LogicalKeyboardKey.keyP) {
        Save.saveGame();
      }
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        enter();
      }
      //if (event.logicalKey == LogicalKeyboardKey.space) {
      //  attack();
      //}
    } else if (event is KeyUpEvent) {
      //if (event.logicalKey == LogicalKeyboardKey.space &&
      //    Weapon.isChargingShot) {
      //  Weapon.releaseShot(worldMousePosition);
      //}

      _pressedKeys.remove(event.logicalKey);
    }
  }

  static void updatePlayerMovement() {
    // Apply acceleration based on pressed keys
    if (_pressedKeys.contains(LogicalKeyboardKey.keyW)) {
      Player.body.yVelocity -= acceleration;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.keyS)) {
      Player.body.yVelocity += acceleration;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.keyA)) {
      Player.body.xVelocity -= acceleration;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.keyD)) {
      Player.body.xVelocity += acceleration;
    }

    // Apply friction to player
    Player.body.xVelocity *= friction;
    Player.body.yVelocity *= friction;

    // Limit player speed
    final currentSpeed = sqrt(
      Player.body.xVelocity * Player.body.xVelocity +
          Player.body.yVelocity * Player.body.yVelocity,
    );

    if (currentSpeed > maxSpeed) {
      final ratio = maxSpeed / currentSpeed;
      Player.body.xVelocity *= ratio;
      Player.body.yVelocity *= ratio;
    }

    // Stop very small movements
    if (Player.body.xVelocity.abs() < minMovementThreshold) {
      Player.body.xVelocity = 0;
    }
    if (Player.body.yVelocity.abs() < minMovementThreshold) {
      Player.body.yVelocity = 0;
    }
  }

  static Widget build(Camera camera) {
    var image = AssetManager().getImage('sword');

    return Positioned(
      left: Player.body.x - camera.x,
      top: Player.body.y - camera.y,
      child: Container(
        width: Player.body.width,
        height: Player.body.height,
        decoration: BoxDecoration(
          //color: Player.body.color,
          borderRadius: BorderRadius.circular(8),
          //boxShadow: [
          //  BoxShadow(
          //    color: Colors.black.withAlpha(50),
          //    blurRadius: 5,
          //    offset: const Offset(2, 2),
          //  ),
          //],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //const Text(
              //  "Hero",
              //  style: TextStyle(
              //    color: Colors.white,
              //    fontWeight: FontWeight.bold,
              //  ),
              //),
              //Text(
              //  'v: (${Player.body.xVelocity.toStringAsFixed(1)}, ${Player.body.yVelocity.toStringAsFixed(1)})',
              //  style: const TextStyle(color: Colors.white, fontSize: 10),
              //),
              //Text(
              //  Player.lives.toString(),
              //  style: TextStyle(color: Colors.white, fontSize: 10),
              //),
              //Image(image: AssetImage('assets/images/player.png')), // Replaced with CustomPaint
              CustomPaint(
                size: Size(Player.body.width, Player.body.height), // Use player body size
                painter: _PlayerPainter(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Convert Player static state to a JSON map
  static Map<String, dynamic> toJson() => {
    'lives': lives,
    'score': score, // Assuming score is part of player state, adjust if needed
    'body': body.toJson(), // Serialize the Body object
    'weapon': Weapon.kind.name, // Save current weapon enum name
    // Add other relevant static player state if necessary
  };

  /// Load Player static state from a JSON map
  static void fromJson(Map<String, dynamic> json) {
    lives = json['lives'] as int;
    score = json['score'] as int; // Adjust if score is stored elsewhere
    body = Body.fromJson(json['body'] as Map<String, dynamic>);
    Weapon.kind = Weapons.values.firstWhere(
      (e) => e.name == (json['weapon'] as String),
    );
    // Load other relevant static player state if necessary
  }
}

/// Custom Painter to draw a specific portion of the player sprite
class _PlayerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final playerImage = AssetManager().getImage('hero'); // Get the preloaded image

    if (playerImage != null) {
      // Define the source rectangle (top-left 48x48 pixels)
      final srcRect = Rect.fromLTWH(0, 0, 48, 48);

      // Define the destination rectangle (the full size of the CustomPaint area)
      final dstRect = Rect.fromLTWH(0, 0, size.width, size.height);

      // Draw the specified portion of the image onto the canvas
      canvas.drawImageRect(
        playerImage,
        srcRect,
        dstRect,
        Paint()..filterQuality = FilterQuality.none, // Use nearest neighbor scaling
      );
    } else {
      // Optional: Draw a placeholder if the image isn't loaded
      final errorPaint = Paint()..color = Colors.red;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), errorPaint);
      // You might want to log an error here as well
      print("Error: Player image 'hero' not found in AssetManager.");
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Repaint only if necessary (e.g., if the sprite frame changes)
    // For a static sprite portion, returning false is efficient.
    // If animation is added later, this condition will need to change.
    return false;
  }
}
