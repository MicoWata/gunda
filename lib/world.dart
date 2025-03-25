import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TileMap {
  static var level = 1;
  static var tileSize = 64.0;
  static List<List<int>> map = [];

  static Future<void> loadMap() async {
    final String source =
        TileMap.level == 0
            ? 'assets/images/map32.txt'
            : 'assets/images/_town.txt';
    final String mapData = await rootBundle.loadString(source);
    final List<String> rows = mapData.trim().split('\n');
    map =
        rows
            .map((row) => row.trim().split(' ').map(int.parse).toList())
            .toList();
  }

  static Point<int> getTilePosition(double screenX, double screenY) {
    return Point<int>(
      (screenX ~/ TileMap.tileSize),
      (screenY ~/ TileMap.tileSize),
    );
  }

  static Point<double> getScreenPosition(int tileX, int tileY) {
    return Point<double>(tileX * TileMap.tileSize, tileY * TileMap.tileSize);
  }

  static bool isValidTile(int x, int y) {
    return y >= 0 && y < map.length && x >= 0 && x < map[0].length;
  }

  static int getTileType(int x, int y) {
    if (!isValidTile(x, y)) return -1;
    return map[y][x];
  }
}

class TileMapPainter extends CustomPainter {
  final List<ui.Image> tileImages;
  final Key reloadKey;

  TileMapPainter({required this.tileImages, required this.reloadKey});

  @override
  void paint(Canvas canvas, Size size) {
    //final floorImage = tileImages[0];
    //final wallImage = tileImages[1];

    for (int y = 0; y < TileMap.map.length; y++) {
      for (int x = 0; x < TileMap.map[y].length; x++) {
        //final image = TileMap.map[y][x] == 1 ? wallImage : floorImage;

        final image = tileImages[TileMap.map[y][x]];

        //  var img = floorImage;
        //
        //  switch (TileMap.map[y][x]) {
        //    case 1:
        //      img = wallImage;
        //case 2:
        //  img = tile
        //  }

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
