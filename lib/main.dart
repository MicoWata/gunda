import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:zeldong/hero.dart';
import 'package:zeldong/world.dart';

void main() {
  runApp(const GameApp());
}

class GameApp extends StatelessWidget {
  const GameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pixel Art Game',
      theme: ThemeData(brightness: Brightness.dark),
      home: const GameScreen(),
    );
  }
}
