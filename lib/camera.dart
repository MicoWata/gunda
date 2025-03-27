import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:zeldong/game.dart';
import 'package:zeldong/hero.dart';
import 'package:zeldong/pawn.dart';
import 'package:zeldong/world.dart';

class Camera extends StatefulWidget {
  final List<ui.Image> tileImages;
  final Key reloadKey;

  const Camera({required this.tileImages, required this.reloadKey, super.key});

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  Offset cameraOffset = Offset.zero;
  final ValueNotifier<Offset> playerPosition = ValueNotifier<Offset>(Offset.zero);

  @override
  void dispose() {
    playerPosition.dispose();
    super.dispose();
  }

  void updateCamera(double playerX, double playerY) {
    final viewportWidth = Game.size.width;
    final viewportHeight = Game.size.height;
    final mapWidth = TileMap.tileSize * TileMap.map[0].length;
    final mapHeight = TileMap.tileSize * TileMap.map.length;

    double offsetX = -(playerX - viewportWidth / 2);
    double offsetY = -(playerY - viewportHeight / 2);

    // Empêcher la caméra de bouger si on atteint le bord gauche ou droit
    if (offsetX > 0) offsetX = 0;
    if (offsetX < -(mapWidth - viewportWidth)) {
      offsetX = -(mapWidth - viewportWidth);
    }

    // Empêcher la caméra de bouger si on atteint le bord haut ou bas
    if (offsetY > 0) offsetY = 0;
    if (offsetY < -(mapHeight - viewportHeight)) {
      offsetY = -(mapHeight - viewportHeight);
    }

    setState(() {
      cameraOffset = Offset(offsetX, offsetY);
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
              Player(
                onMove: updateCamera,
                positionNotifier: playerPosition,
              ),
              Pawn(
                x: 64 * 16, 
                y: 64 * 12,
                playerPosition: playerPosition,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
