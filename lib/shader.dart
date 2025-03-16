import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

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
      duration: const Duration(seconds: 2), // Adjust duration as needed
    )..repeat(); // Makes the animation loop
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderBuilder(
          assetKey: 'shaders/shader.frag',
          (context, shader, child) => CustomPaint(
            size: const Size(800, 600),
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
  ShaderPainter({
    required this.shader,
    required this.time, // Add time parameter
  });

  ui.FragmentShader shader;
  final double time;

  @override
  void paint(Canvas canvas, Size size) {
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setFloat(2, time); // Pass time to shader

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

//class ShaderScaffoldExample extends StatefulWidget {
//  final Widget child;
//  final Duration duration;
//
//  const ShaderScaffoldExample({
//    super.key,
//    required this.child,
//    this.duration = const Duration(seconds: 1),
//  });
//
//  @override
//  State<ShaderScaffoldExample> createState() => _ShaderScaffoldExampleState();
//}
//
//class _ShaderScaffoldExampleState extends State<ShaderScaffoldExample> {
//  double _progress = 0.0;
//  Timer? _timer;
//
//  @override
//  void initState() {
//    super.initState();
//    _startTimer();
//  }
//
//  void _startTimer() {
//    // Update every 100ms instead of every frame
//    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
//      setState(() {
//        _progress = (_progress + 0.1) % 1.0;
//      });
//    });
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      body: ShaderMask(
//        blendMode: BlendMode.srcATop,
//        shaderCallback: (Rect bounds) {
//          return LinearGradient(
//            begin: Alignment.topLeft,
//            end: Alignment.bottomRight,
//            colors: [Colors.white, Colors.black],
//            stops: [_progress, (_progress + 0.5) % 1.0],
//          ).createShader(bounds);
//        },
//        child: widget.child,
//      ),
//    );
//  }
//
//  @override
//  void dispose() {
//    _timer?.cancel();
//    super.dispose();
//  }
//}

//import 'dart:math';
//import 'dart:ui';
//
//import 'package:flutter/material.dart';
//
//class ShaderScaffoldExample extends StatefulWidget {
//  final Center child;
//  final Duration animationDuration;
//  final String shaderAsset;
//
//  const ShaderScaffoldExample({
//    super.key,
//    required this.child,
//    this.animationDuration = const Duration(seconds: 1),
//    this.shaderAsset = 'shaders/shader.frag',
//  });
//
//  @override
//  State<ShaderScaffoldExample> createState() => _ShaderScaffoldExampleState();
//}
//
//class _ShaderScaffoldExampleState extends State<ShaderScaffoldExample>
//    with SingleTickerProviderStateMixin {
//  FragmentProgram? _program;
//  FragmentShader? _shader;
//  late final AnimationController _controller;
//  bool _shaderLoadError = false;
//  late final Shader _fallbackShader;
//
//  @override
//  void initState() {
//    super.initState();
//
//    // Create fallback shader once
//    _fallbackShader = const LinearGradient(
//      begin: Alignment.topLeft,
//      end: Alignment.bottomRight,
//      colors: [Colors.white, Colors.black],
//    ).createShader(const Rect.fromLTWH(0, 0, 1, 1));
//
//    _controller = AnimationController(
//      vsync: this,
//      duration: widget.animationDuration,
//    );
//
//    _loadShader();
//  }
//
//  Future<void> _loadShader() async {
//    try {
//      final program = await FragmentProgram.fromAsset(widget.shaderAsset);
//      if (!mounted) return;
//
//      setState(() {
//        _program = program;
//        _shader = program.fragmentShader();
//      });
//      _controller.repeat(); // Start animation after shader is loaded
//    } catch (e) {
//      if (!mounted) return;
//      setState(() => _shaderLoadError = true);
//      debugPrint('Error loading shader: $e');
//    }
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      body: AnimatedBuilder(
//        animation: _controller,
//        child: widget.child,
//        builder: (context, child) {
//          return ShaderMask(
//            blendMode: BlendMode.srcATop,
//            shaderCallback: (Rect bounds) {
//              if (_shader == null || _shaderLoadError) {
//                return _fallbackShader;
//              }
//              return _shader!
//                ..setFloat(0, bounds.width)
//                ..setFloat(1, bounds.height)
//                ..setFloat(2, _controller.value * 2 * pi);
//            },
//            child: child!,
//          );
//        },
//      ),
//    );
//  }
//
//  @override
//  void dispose() {
//    _controller.dispose();
//    _shader?.dispose();
//    super.dispose();
//  }
//}
