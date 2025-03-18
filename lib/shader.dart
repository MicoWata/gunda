import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:zeldong/game.dart';

class Veil extends StatefulWidget {
  final Duration duration;
  const Veil({super.key, this.duration = const Duration(seconds: 1)});

  @override
  State<Veil> createState() => _VeilState();
}

class _VeilState extends State<Veil> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Adjust duration as needed
    )..repeat(); // Makes the animation loop
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderBuilder(
          assetKey: 'shaders/shader.glsl',
          (context, shader, child) => CustomPaint(
            size: Game.size,
            painter: ShaderPainter(
              shader: shader,
              time: _controller.value * 2 * pi, // Convert to radians
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class ShaderPainter extends CustomPainter {
  final double time;
  ui.FragmentShader shader;

  ShaderPainter({required this.shader, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setFloat(2, time);

    final paint =
        Paint()
          ..shader = shader
          ..blendMode = BlendMode.multiply;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant ShaderPainter oldDelegate) {
    return oldDelegate.time != time; // Repaint when time changes
  }
}
