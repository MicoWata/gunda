import 'dart:math';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:zeldong/camera.dart';
import 'package:zeldong/home.dart';
import 'package:zeldong/menu.dart';
import 'package:zeldong/pause.dart';
import 'package:zeldong/shader.dart';
import 'package:zeldong/world.dart';

class Game extends StatefulWidget {
  static var size = Size(0, 0);

  const Game({super.key});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  List<ui.Image>? _tileImages;
  bool _isLoading = true;
  bool paused = false;
  bool started = true;

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    try {
      await TileMap.loadMap();
      final images = await loadTileImages();
      setState(() {
        _tileImages = images;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading assets: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Game.size = Size(
      min(MediaQuery.of(context).size.width, 64 * 16),
      min(MediaQuery.of(context).size.height, 64 * 8),
    );

    return Scaffold(
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Menu(),
              Center(
                child: Stack(
                  children: [
                    _isLoading
                        ? const CircularProgressIndicator()
                        : _tileImages == null
                        ? const Text('Failed to load assets')
                        : SizedBox(
                          width: Game.size.width,
                          height: Game.size.height,
                          child: ClipRect(
                            child: Camera(
                              tileImages: _tileImages!,
                              reloadKey: ValueKey(_tileImages.hashCode),
                            ),
                          ),
                        ),
                    Veil(),
                  ],
                ),
              ),
            ],
          ),
          Pause(key: modalKey),
          Home(key: homeKey),
          //Center(child: Veil()),
        ],
      ),
    );
  }
}

Future<List<ui.Image>> loadTileImages() async {
  final floorCompleter = Completer<ui.Image>();
  final wallCompleter = Completer<ui.Image>();
  final pawnCompleter = Completer<ui.Image>();

  final floorImage =
      TileMap.level == 0
          ? AssetImage('assets/images/tile_0049.png')
          : AssetImage('assets/images/tile_0201.png');
  final wallImage =
      TileMap.level == 0
          ? AssetImage('assets/images/tile_0040.png')
          : AssetImage('assets/images/tile_0243.png');
  final pawnImage =
      TileMap.level == 0
          ? AssetImage('assets/images/tile_0110.png')
          : AssetImage('assets/images/tile_0099.png');

  floorImage
      .resolve(ImageConfiguration())
      .addListener(
        ImageStreamListener((ImageInfo info, bool _) {
          floorCompleter.complete(info.image);
        }),
      );

  wallImage
      .resolve(ImageConfiguration())
      .addListener(
        ImageStreamListener((ImageInfo info, bool _) {
          wallCompleter.complete(info.image);
        }),
      );

  pawnImage
      .resolve(ImageConfiguration())
      .addListener(
        ImageStreamListener((ImageInfo info, bool _) {
          pawnCompleter.complete(info.image);
        }),
      );

  return Future.wait([
    floorCompleter.future,
    wallCompleter.future,
    pawnCompleter.future,
  ]);
}
