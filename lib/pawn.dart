import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zeldong/home.dart';
import 'package:zeldong/pause.dart';
import 'package:zeldong/world.dart';

class Pawn extends StatefulWidget {
  const Pawn({super.key});

  @override
  PawnState createState() => PawnState();
}

class PawnState extends State<Pawn> {
  int hearts = 3;
  int keys = 0;
  int coins = 0;
  double _x = 64 * 16;
  double _y = 64 * 12;
  final double _step = 16;

  @override
  void initState() {
    super.initState();
  }

  bool canMove(double newX, double newY) {
    final heroRect = Rect.fromLTWH(
      newX + 0,
      newY + 0,
      TileMap.tileSize - 0,
      TileMap.tileSize - 0,
    );

    final startTile = TileMap.getTilePosition(heroRect.left, heroRect.top);
    final endTile = TileMap.getTilePosition(heroRect.right, heroRect.bottom);

    for (int x = startTile.x; x <= endTile.x; x++) {
      for (int y = startTile.y; y <= endTile.y; y++) {
        if (TileMap.getTileType(x, y) == 1) {
          final tileRect = Rect.fromLTWH(
            x * TileMap.tileSize.toDouble(),
            y * TileMap.tileSize.toDouble(),
            TileMap.tileSize.toDouble(),
            TileMap.tileSize.toDouble(),
          );

          if (heroRect.overlaps(tileRect)) {
            return false;
          }
        }
      }
    }

    return true;
  }

  void updatePosition(double newX, double newY) {
    if (canMove(newX, newY)) {
      setState(() {
        _x = newX;
        _y = newY;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: TileMap.tileSize * TileMap.map[0].length,
      height: TileMap.tileSize * TileMap.map.length,
      child: CustomPaint(
        size: Size(
          TileMap.tileSize * TileMap.map[0].length,
          TileMap.tileSize * TileMap.map.length,
        ),
        painter: PawnPainter(x: _x, y: _y),
      ),
    );
  }
}

class PawnPainter extends CustomPainter {
  final double x;
  final double y;
  ui.Image? heroImage;

  PawnPainter({required this.x, required this.y}) {
    _loadHeroImage();
  }

  Future<void> _loadHeroImage() async {
    final completer = Completer<ui.Image>();
    final imageProvider =
        TileMap.level == 0
            ? AssetImage('assets/images/tile_0108.png')
            : AssetImage('assets/images/tile_0099.png');
    imageProvider
        .resolve(const ImageConfiguration())
        .addListener(
          ImageStreamListener((ImageInfo info, bool _) {
            completer.complete(info.image);
            heroImage = info.image;
          }),
        );
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (heroImage != null) {
      canvas.drawImageRect(
        heroImage!,
        Rect.fromLTWH(
          0,
          0,
          heroImage!.width.toDouble(),
          heroImage!.height.toDouble(),
        ),
        Rect.fromLTWH(x, y, TileMap.tileSize, TileMap.tileSize),
        Paint()..filterQuality = FilterQuality.none,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PawnPainter oldDelegate) {
    return x != oldDelegate.x || y != oldDelegate.y;
  }
}
