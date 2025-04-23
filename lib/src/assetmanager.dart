import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class AssetManager {
  static final AssetManager _instance = AssetManager._internal();
  factory AssetManager() => _instance;
  AssetManager._internal();

  final Map<String, ui.Image> _images = {};
  final Map<String, List<ui.Image>> _spriteSheets = {};
  static final Map<String, AudioPlayer> _sounds = {};

  static final AudioCache _audioCache = AudioCache(prefix: 'assets/sounds/');

  Future<ui.Image> _loadUiImage(String path) async {
    final ByteData data = await rootBundle.load(path);
    final Uint8List bytes = Uint8List.view(data.buffer);
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(bytes, (img) => completer.complete(img));
    return completer.future;
  }

  Future<void> loadImage(String key, String path) async {
    if (_images.containsKey(key)) return;
    final img = await _loadUiImage(path);
    _images[key] = img;
  }

  Future<List<ui.Image>> loadSpriteSequence(
    String key,
    String folderPath,
    int frameCount,
  ) async {
    if (_spriteSheets.containsKey(key)) {
      return _spriteSheets[key]!;
    }

    final frames = <ui.Image>[];
    for (int i = 0; i < frameCount; i++) {
      final path = '$folderPath/$i.png';
      final img = await _loadUiImage(path);
      frames.add(img);
    }

    _spriteSheets[key] = frames;
    return frames;
  }

  static Future<void> loadSound(String key, String fileName) async {
    final player = await _audioCache.loadAsFile(fileName);
    _sounds[key] = AudioPlayer()..setSourceDeviceFile(player.path);
  }

  ui.Image? getImage(String key) => _images[key];

  List<ui.Image>? getSpriteSequence(String key) => _spriteSheets[key];

  static Future<void> playSound(String key) async {
    final sound = _sounds[key];
    if (sound != null) {
      await sound.stop(); // to allow replaying instantly
      await sound.resume();
    }
  }

  Future<void> loadAllAssets() async {
    await Future.wait([
      loadImage('sword', 'assets/images/sword.png'),
      loadImage('pistol', 'assets/images/pistol.png'),
      loadImage('shotgun', 'assets/images/shotgun.png'),
      loadImage('bazooka', 'assets/images/bazooka.png'),
      loadImage('hero', 'assets/sprites/player.png'),
      // loadSpriteSequence('player_idle', 'sprites/player', 1),
      // loadSpriteSequence('demon_idle', 'assets/sprites/demon/idle.png', 1),
      // loadSound('shoot', 'shoot.wav'),
    ]);
  }
}
