import 'package:flutter/material.dart';
import 'package:zeldong/game.dart';

void main() {
  runApp(const GameApp());
}

class GameApp extends StatefulWidget {
  const GameApp({super.key});

  @override
  State<GameApp> createState() => _GameAppState();
}

class _GameAppState extends State<GameApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gunda',
      theme: ThemeData(brightness: Brightness.dark, fontFamily: 'GameFont'),
      home: const Game(),
    );
  }
}
