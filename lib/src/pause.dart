import 'package:flutter/material.dart';
import 'package:gunda/src/app.dart';
import 'package:gunda/src/game.dart';

class Pause extends StatefulWidget {
  const Pause({Key? key}) : super(key: key);

  @override
  State<Pause> createState() => _PauseState();
}

class _PauseState extends State<Pause> {
  Widget keepup() {
    return ElevatedButton(
      onPressed: () {
        // Update state and trigger rebuild
        setState(() {
          Game.paused = false;
        });
        App.snack('HE');
      },
      style: ButtonStyle(
        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
          const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        ),
      ),
      child: const Text('Continue', style: TextStyle(fontSize: 20)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Game.paused
        ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'PAUSE',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 50),
              keepup(),
            ],
          ),
        )
        : Container();
  }
}
