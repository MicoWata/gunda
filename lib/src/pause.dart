import 'package:flutter/material.dart';
import 'package:gunda/src/app.dart';
import 'package:gunda/src/game.dart';
import 'package:gunda/src/save.dart';

class Pause extends StatelessWidget {
  const Pause({super.key});

  Widget keepup() {
    return ElevatedButton(
      onPressed: () {
        // Directly modify the static state.
        // The App widget's rebuild mechanism will handle hiding the overlay.
        Game.paused = false;
      },
      style: ButtonStyle(
        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
          // Use MaterialStateProperty
          const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        ),
        // Optional: Add background/foreground colors if needed
        // backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
        // foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
      ),
      child: const Text('Continue', style: TextStyle(fontSize: 20)),
    );
  }

  Widget save() {
    return ElevatedButton(
      onPressed: () {
        // Directly modify the static state.
        // The App widget's rebuild mechanism will handle hiding the overlay.
        Game.paused = false;
        Save.saveGame();
      },
      style: ButtonStyle(
        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
          // Use MaterialStateProperty
          const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        ),
        // Optional: Add background/foreground colors if needed
        // backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
        // foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
      ),
      child: const Text('Save Game', style: TextStyle(fontSize: 20)),
    );
  }

  Widget quit() {
    return ElevatedButton(
      onPressed: () {
        App.reset = true;
      },
      style: ButtonStyle(
        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
          const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        ),
      ),
      child: const Text('Quit', style: TextStyle(fontSize: 20)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This widget is only built when Game.paused is true,
    // so we don't need to check it again here.
    return Container(
      color: Colors.deepPurple,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              // Added const
              'PAUSE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 50),
            keepup(),
            const SizedBox(height: 40),
            save(),
            const SizedBox(height: 40),
            quit(),
          ],
        ),
      ),
    );
  }
}
