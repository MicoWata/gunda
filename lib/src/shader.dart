import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:gunda/src/level.dart';

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
            size: Level.size,
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

// --- Dirty Pixel Shader Widget ---

class DirtyPixel extends StatefulWidget {
  final Duration duration;
  const DirtyPixel({super.key, this.duration = const Duration(seconds: 5)});

  @override
  State<DirtyPixel> createState() => _DirtyPixelState();
}

class _DirtyPixelState extends State<DirtyPixel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration, // Use duration from widget
    )..repeat(); // Makes the animation loop
  }

  @override
  Widget build(BuildContext context) {
    // Use AnimatedBuilder to rebuild the ShaderBuilder whenever the animation ticks
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // ShaderBuilder loads and provides the shader program
        return ShaderBuilder(
          assetKey: 'shaders/dirty_pixel.glsl', // Path to the new shader
          (context, shader, child) => CustomPaint(
            // Use the full size available (likely the game area size)
            size: Size.infinite,
            // Pass the shader and the current animation time to the painter
            painter: DirtyPixelPainter(
              shader: shader,
              time: _controller.value * 10, // Pass time, scale if needed
            ),
          ),
          // Optional: Placeholder while the shader is loading
          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the animation controller
    super.dispose();
  }
}

// --- Dirty Pixel Custom Painter ---

class DirtyPixelPainter extends CustomPainter {
  final double time; // Current animation time
  final ui.FragmentShader shader; // The compiled shader program

  DirtyPixelPainter({required this.shader, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    // Set shader uniforms:
    //Uniform 0: Resolution (width, height of the paint area)
    shader.setFloat(0, size.width / 128);
    shader.setFloat(1, size.height / 64);
    // Uniform 2: Time (for animation)
    shader.setFloat(2, time);

    // Create a Paint object that uses the shader
    final paint = Paint()..shader = shader;
    // Optional: Set blend mode if you want to blend with underlying content
    // paint.blendMode = BlendMode.srcOver; // Example: Normal blending

    // Draw a rectangle covering the entire canvas, applying the shader effect
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant DirtyPixelPainter oldDelegate) {
    // Repaint only if the time has changed, optimizing performance
    return oldDelegate.time != time;
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
