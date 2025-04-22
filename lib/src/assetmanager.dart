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
  final Map<String, AudioPlayer> _sounds = {};

  final AudioCache _audioCache = AudioCache(prefix: 'assets/sounds/');

  Future<ui.Image> _loadUiImage(String path) async {
    final ByteData data = await rootBundle.load(path);
    final Uint8List bytes = Uint8List.view(data.buffer);
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(bytes, (img) => completer.complete(img));
    return completer.future;
  }

  Future<void> loadImage(String key, String path) async {
    final img = await _loadUiImage(path);
    _images[key] = img;
  }

  Future<void> loadSpriteSequence(
    String key,
    String folderPath,
    int frameCount,
  ) async {
    final frames = <ui.Image>[];
    for (int i = 0; i < frameCount; i++) {
      final path = '$folderPath/$i.png';
      final img = await _loadUiImage(path);
      frames.add(img);
    }
    _spriteSheets[key] = frames;
  }

  Future<void> loadSound(String key, String fileName) async {
    final player = await _audioCache.loadAsFile(fileName);
    _sounds[key] = AudioPlayer()..setSourceDeviceFile(player.path);
  }

  ui.Image? getImage(String key) => _images[key];

  List<ui.Image>? getSpriteSequence(String key) => _spriteSheets[key];

  Future<void> playSound(String key) async {
    final sound = _sounds[key];
    if (sound != null) {
      await sound.stop(); // to allow replaying instantly
      await sound.resume();
    }
  }

  Future<void> loadAllAssets() async {
    await Future.wait([
      loadImage('pistol', 'assets/images/pistol.png'),
      loadImage('shotgun', 'assets/images/shotgun.png'),
      loadImage('sword', 'assets/images/sword.png'),
      // loadSpriteSequence('explosion', 'assets/sprites/explosion', 6),
      // loadSound('shoot', 'shoot.wav'),
    ]);
  }
}
