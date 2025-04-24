import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:gunda/src/app.dart';
import 'package:gunda/src/game.dart';

class Pause extends StatelessWidget {
  const Pause({super.key});

  @override
  Widget build(BuildContext context) {
    // This widget is only built when Game.paused is true,
    // so we don't need to check it again here.
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text( // Added const
            'PAUSE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 50),
          ElevatedButton(
            onPressed: () {
              // Directly modify the static state.
              // The App widget's rebuild mechanism will handle hiding the overlay.
              Game.paused = false;
              App.snack('Continue'); // Changed snackbar message for clarity
            },
            style: ButtonStyle(
              padding: MaterialStateProperty.all<EdgeInsetsGeometry>( // Use MaterialStateProperty
                const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              // Optional: Add background/foreground colors if needed
              // backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              // foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            ),
            child: const Text('Continue', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }
}
