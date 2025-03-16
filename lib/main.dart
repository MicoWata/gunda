import 'package:flutter/material.dart';
import 'package:zeldong/world.dart';

void main() {
  runApp(const GameApp());
}

class GameApp extends StatelessWidget {
  const GameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pixel Art Game',
      theme: ThemeData(brightness: Brightness.dark),
      home: const GameScreen(),
    );
  }
}
