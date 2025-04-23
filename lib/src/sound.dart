import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  // Singleton pattern
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  // Map to keep track of preloaded sounds
  final Map<String, AudioPlayer> _players = {};
  
  // Preload sounds for efficient playback
  Future<void> preloadSounds() async {
    final sounds = {
      'pew': 'sounds/pew1.mp3',
      //'explosion': 'sounds/explosion.mp3',
      //'jump': 'sounds/jump.mp3',
      //'coin': 'sounds/coin.mp3',
      //'background': 'sounds/background.mp3',
    };
    
    for (final entry in sounds.entries) {
      final player = AudioPlayer();
      await player.setSource(AssetSource(entry.value));
      _players[entry.key] = player;
    }
  }
  
  // Play a specific sound
  Future<void> playSound(String soundName) async {
    final player = _players[soundName];
    if (player != null) {
      // Seek to the beginning and then play (resume effectively starts from the seek position)
      // Using resume() after seek(Duration.zero) is a common pattern to restart.
      await player.seek(Duration.zero);
      await player.resume();
    } else {
      // Handle sound not found
      print('Sound $soundName not preloaded or failed to load.');
    }
  }
  
  // Play a sound with a unique instance (always plays, even if same sound)
  Future<void> playSoundNew(String assetPath) async {
    final player = AudioPlayer();
    await player.play(AssetSource(assetPath));
    // Auto dispose after completion to avoid memory leaks
    player.onPlayerComplete.listen((event) {
      player.dispose();
    });
  }
  
  // Play multiple specific sounds simultaneously
  Future<void> playMultipleSounds(List<String> soundNames) async {
    for (final name in soundNames) {
      playSound(name);
    }
  }
  
  // Control volume of specific sound
  Future<void> setVolume(String soundName, double volume) async {
    if (_players.containsKey(soundName)) {
      await _players[soundName]!.setVolume(volume); // 0.0 to 1.0
    }
  }
  
  // Dispose all players when app is closed
  void dispose() {
    for (final player in _players.values) {
      player.dispose();
    }
    _players.clear();
  }
}
