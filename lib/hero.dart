import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zeldong/home.dart';
import 'package:zeldong/pause.dart';
import 'package:zeldong/world.dart';

class Player extends StatefulWidget {
  final Function(double, double) onMove;
  final ValueNotifier<Offset> positionNotifier;

  const Player({
    required this.onMove, 
    required this.positionNotifier,
    super.key
  });

  @override
  PlayerState createState() => PlayerState();
}

class PlayerState extends State<Player> {
  int hearts = 3;
  int keys = 0;
  int coins = 0;
  double _x = 64 * 16;
  double _y = 64 * 16;
  final double _step = 16;

  @override
  void initState() {
    super.initState();
    widget.onMove(_x, _y);
    widget.positionNotifier.value = Offset(_x, _y);
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
        widget.onMove(_x, _y);
        widget.positionNotifier.value = Offset(_x, _y);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: TileMap.tileSize * TileMap.map[0].length,
      height: TileMap.tileSize * TileMap.map.length,
      child: Focus(
        autofocus: true,
        onKeyEvent: (FocusNode node, KeyEvent event) {
          if (event is KeyDownEvent) {
            switch (event.logicalKey) {
              case LogicalKeyboardKey.escape:
                modalKey.currentState?.toggle();
                break;
              case LogicalKeyboardKey.space:
                homeKey.currentState?.toggle();
                break;
            }
          }
          switch (event.logicalKey) {
            case LogicalKeyboardKey.arrowLeft:
              updatePosition(_x - _step, _y);
              break;
            case LogicalKeyboardKey.arrowRight:
              updatePosition(_x + _step, _y);
              break;
            case LogicalKeyboardKey.arrowUp:
              updatePosition(_x, _y - _step);
              break;
            case LogicalKeyboardKey.arrowDown:
              updatePosition(_x, _y + _step);
              break;
          }
          return KeyEventResult.handled;
        },
        child: CustomPaint(
          size: Size(
            TileMap.tileSize * TileMap.map[0].length,
            TileMap.tileSize * TileMap.map.length,
          ),
          painter: PlayerPainter(x: _x, y: _y),
        ),
      ),
    );
  }
}

class PlayerPainter extends CustomPainter {
  final double x;
  final double y;
  ui.Image? heroImage;

  PlayerPainter({required this.x, required this.y}) {
    _loadHeroImage();
  }

  Future<void> _loadHeroImage() async {
    final completer = Completer<ui.Image>();
    final imageProvider =
        TileMap.level == 0
            ? AssetImage('assets/images/tile_0096.png')
            : AssetImage('assets/images/tile_0097.png');
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
  bool shouldRepaint(covariant PlayerPainter oldDelegate) {
    return x != oldDelegate.x || y != oldDelegate.y;
  }
}
