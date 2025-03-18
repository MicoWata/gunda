import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:zeldong/game.dart';
import 'package:zeldong/hero.dart';
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

  void updateCamera(double playerX, double playerY) {
    final viewportWidth = Game.size.width;
    final viewportHeight = Game.size.height;

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
              Player(onMove: updateCamera),
            ],
          ),
        ),
      ),
    );
  }
}
