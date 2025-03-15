import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zeldong/hero.dart';

class TileMap {
  static const tileSize = 64.0;
  static List<List<int>> map = [];

  static Future<void> loadMap() async {
    final String mapData = await rootBundle.loadString('assets/images/map32.txt');
    final List<String> rows = mapData.trim().split('\n');
    map = rows.map((row) => row.trim().split(' ').map(int.parse).toList()).toList();
  }

  static Point<int> getTilePosition(double screenX, double screenY) {
    return Point<int>((screenX ~/ tileSize), (screenY ~/ tileSize));
  }

  static Point<double> getScreenPosition(int tileX, int tileY) {
    return Point<double>(tileX * tileSize, tileY * tileSize);
  }

  static bool isValidTile(int x, int y) {
    return y >= 0 && y < map.length && x >= 0 && x < map[0].length;
  }

  static int getTileType(int x, int y) {
    if (!isValidTile(x, y)) return -1;
    return map[y][x];
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<ui.Image>? _tileImages;
  bool _isLoading = true;

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
    return Scaffold(
      body: Center(
        child: _isLoading 
          ? const CircularProgressIndicator()
          : _tileImages == null
            ? const Text('Failed to load assets')
            : SizedBox(
                width: 800,
                height: 600,
                child: ClipRect(
                  child: GameView(
                    tileImages: _tileImages!,
                    reloadKey: ValueKey(_tileImages.hashCode),
                  ),
                ),
              ),
      ),
    );
  }
}

class GameView extends StatefulWidget {
  final List<ui.Image> tileImages;
  final Key reloadKey;

  const GameView({
    required this.tileImages,
    required this.reloadKey,
    super.key,
  });

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  Offset cameraOffset = Offset.zero;

  void updateCamera(double playerX, double playerY) {
    final viewportWidth = 800.0;
    final viewportHeight = 600.0;
    
    setState(() {
      // Center the camera on the player
      cameraOffset = Offset(
        -(playerX - viewportWidth / 2),
        -(playerY - viewportHeight / 2),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: TileMap.tileSize * TileMap.map[0].length,
      height: TileMap.tileSize * TileMap.map.length,
      child: ClipRect(
        child: Transform.translate(
          offset: cameraOffset,
          child: Stack(
            children: [
              CustomPaint(
                size: Size(
                  TileMap.tileSize * TileMap.map[0].length,
                  TileMap.tileSize * TileMap.map.length,
                ),
                painter: TileMapPainter(
                  tileImages: widget.tileImages,
                  reloadKey: widget.reloadKey,
                ),
              ),
              MovableImage(onMove: updateCamera),
            ],
          ),
        ),
      ),
    );
  }
}

Future<List<ui.Image>> loadTileImages() async {
  final floorCompleter = Completer<ui.Image>();
  final wallCompleter = Completer<ui.Image>();

  final floorImage = AssetImage('assets/images/tile_0049.png');
  final wallImage = AssetImage('assets/images/tile_0040.png');

  floorImage.resolve(ImageConfiguration()).addListener(
    ImageStreamListener((ImageInfo info, bool _) {
      floorCompleter.complete(info.image);
    }),
  );

  wallImage.resolve(ImageConfiguration()).addListener(
    ImageStreamListener((ImageInfo info, bool _) {
      wallCompleter.complete(info.image);
    }),
  );

  return Future.wait([floorCompleter.future, wallCompleter.future]);
}

class TileMapPainter extends CustomPainter {
  final List<ui.Image> tileImages;
  final Key reloadKey;

  TileMapPainter({required this.tileImages, required this.reloadKey});

  @override
  void paint(Canvas canvas, Size size) {
    final floorImage = tileImages[0];
    final wallImage = tileImages[1];

    for (int y = 0; y < TileMap.map.length; y++) {
      for (int x = 0; x < TileMap.map[y].length; x++) {
        final image = TileMap.map[y][x] == 1 ? wallImage : floorImage;
        canvas.drawImageRect(
          image,
          Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
          Rect.fromLTWH(
            x * TileMap.tileSize,
            y * TileMap.tileSize,
            TileMap.tileSize,
            TileMap.tileSize,
          ),
          Paint()..filterQuality = FilterQuality.none,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant TileMapPainter oldDelegate) =>
      tileImages != oldDelegate.tileImages ||
      reloadKey != oldDelegate.reloadKey;
}
