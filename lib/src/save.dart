import 'dart:convert'; // For jsonEncode/Decode
// Remove dart:io and path_provider imports
// import 'dart:io'; // For File operations
// import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart'; // Required for Color
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'package:gunda/src/app.dart'; // For App.snack
import 'package:gunda/src/game.dart';
import 'package:gunda/src/level.dart';
import 'package:gunda/src/player.dart';
import 'package:gunda/src/mob.dart';
import 'package:gunda/src/ball.dart';
import 'package:gunda/src/drop.dart';
import 'package:gunda/src/obstacle.dart';
import 'package:gunda/src/body.dart';
import 'package:gunda/src/effect.dart'; // For clearing effects
import 'package:gunda/src/weapon.dart'; // For resetting weapon state

class Save {
  static const String _saveFileName = 'gunda_savegame.json';
  static final Save _instance = Save._internal(); // Singleton pattern
  factory Save() => _instance;
  Save._internal();

  // Remove file system path/file getters

  /// Save the current game state using SharedPreferences
  static Future<void> saveGame() async {
    // Prevent saving if game is over or paused? Or allow? Currently allows.
    // if (Game.over || Game.paused) return;

    try {
      // Get SharedPreferences instance
      final prefs = await SharedPreferences.getInstance();

      // 1. Gather all game state data
      final gameState = {
        'game': {
          'level': Game.level,
          'score': Game.score,
          // Add other Game static fields if needed (e.g., camera position?)
          // 'camera_x': Game.camera.x,
          // 'camera_y': Game.camera.y,
        },
        'player': Player.toJson(), // Use the static toJson method
        'level': {
          'remaining': Level.remaining,
          'benching': Level.benching,
          'maxMob': Level.maxMob, // Save maxMob too
          'allMob': Level.allMob, // Save allMob too
          'enemies': Level.enemies.map((e) => e.toJson()).toList(),
          'projectiles': Level.projectiles.map((p) => p.toJson()).toList(),
          'obstacles': Level.obstacles.map((o) => o.toJson()).toList(),
          'drops': Level.drops.map((d) => d.toJson()).toList(),
          // Note: impactParticles are usually transient effects, maybe don't save?
        },
        // Add other major components if necessary
      };

      // 2. Convert game state to JSON string
      // Use JsonEncoder for pretty printing if desired during debugging
      // final jsonString = JsonEncoder.withIndent('  ').convert(gameState);
      final jsonString = jsonEncode(gameState);

      // 3. Write JSON string to SharedPreferences
      await prefs.setString(_saveFileName, jsonString);

      print('Game saved successfully using SharedPreferences.');
      App.snack('Game Saved!'); // Use the snackbar helper
    } catch (e, stacktrace) {
      print('Error saving game: $e');
      print(stacktrace); // Print stacktrace for debugging
      App.snack('Error saving game: $e');
    }
  }

  /// Load game state from SharedPreferences
  static Future<bool> loadGame() async {
    try {
      // Get SharedPreferences instance
      final prefs = await SharedPreferences.getInstance();

      // Check if save data exists
      if (!prefs.containsKey(_saveFileName)) {
        print('Save data not found in SharedPreferences.');
        App.snack('No save data found.');
        return false;
      }

      // Read JSON string from SharedPreferences
      final jsonString = prefs.getString(_saveFileName);
      if (jsonString == null) {
        print('Failed to retrieve save data string.');
        App.snack('Error reading save data.');
        return false; // Handle null case
      }

      // Decode JSON string to a map
      final gameState = jsonDecode(jsonString) as Map<String, dynamic>;

      // --- Restore Game State ---
      // Game
      final gameData = gameState['game'] as Map<String, dynamic>;
      Game.level = gameData['level'] as int;
      Game.score = gameData['score'] as int;
      // Game.camera.x = gameData['camera_x'] ?? 0; // Example if saving camera
      // Game.camera.y = gameData['camera_y'] ?? 0;

      // Player
      final playerData = gameState['player'] as Map<String, dynamic>;
      Player.fromJson(playerData); // Use the static fromJson method

      // Level
      final levelData = gameState['level'] as Map<String, dynamic>;
      Level.remaining = levelData['remaining'] as int;
      Level.benching = levelData['benching'] as int;
      Level.maxMob = levelData['maxMob'] as int; // Restore maxMob
      Level.allMob = levelData['allMob'] as int; // Restore allMob

      Level.enemies.clear();
      Level.enemies.addAll(
        (levelData['enemies'] as List)
            .map((e) => Enemy.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

      Level.projectiles.clear();
      Level.projectiles.addAll(
        (levelData['projectiles'] as List)
            .map((p) => Projectile.fromJson(p as Map<String, dynamic>))
            .toList(),
      );

      // Obstacles might need special handling if they depend on level layout
      // If obstacles are always generated by TileMap, maybe don't save/load them,
      // just call Level.initializeObstacles() after loading?
      // For now, we load them as saved.
      Level.obstacles.clear();
      Level.obstacles.addAll(
        (levelData['obstacles'] as List)
            .map((o) => Obstacle.fromJson(o as Map<String, dynamic>))
            .toList(),
      );
      // If obstacles are generated, you might call this instead:
      // await Level.initializeObstacles(); // Make sure TileMap is loaded if needed

      Level.drops.clear();
      Level.drops.addAll(
        (levelData['drops'] as List)
            .map((d) => Drop.fromJson(d as Map<String, dynamic>))
            .toList(),
      );

      // Clear transient effects
      Level.impactParticles.clear();
      Effect.explosionCircles.clear();
      Game.effect.showSlowMotion = false; // Ensure slow-mo is off

      // Reset flags and states
      Game.paused = false;
      Game.over = false;
      Weapon.isChargingShot = false; // Reset weapon state
      Weapon.slicing = false; // Reset slice state
      // Ensure animation controller is running if it was stopped
      if (!Game.animationController.isAnimating && !Game.paused && !Game.over) {
        Game.animationController.repeat();
      }

      // Crucially, update the camera to the loaded player position
      Game.camera.follow(Player.body); // Initial camera sync

      print('Game loaded successfully from SharedPreferences.');
      App.snack('Game Loaded!');
      return true;
    } catch (e, stacktrace) {
      print('Error loading game: $e');
      print(stacktrace); // Print stacktrace for debugging
      App.snack('Error loading game: $e');
      // Optionally reset to a default state if loading fails
      // Game.reset();
      return false;
    }
  }
}
