import 'dart:ui' as ui;

class SpriteAnimation {
  final List<ui.Image> frames;
  final double frameDuration;
  double _elapsedTime = 0;
  int _currentFrame = 0;

  SpriteAnimation(this.frames, this.frameDuration);

  void update(double delta) {
    _elapsedTime += delta;
    if (_elapsedTime >= frameDuration) {
      _elapsedTime = 0;
      _currentFrame = (_currentFrame + 1) % frames.length;
    }
  }

  ui.Image get currentFrame => frames[_currentFrame];
}
