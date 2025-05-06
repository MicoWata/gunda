import 'package:flutter/material.dart';
import 'package:gunda/src/app.dart';
import 'package:gunda/src/game.dart';
import 'package:gunda/src/level.dart';
import 'package:gunda/src/player.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  Widget quit() {
    return ElevatedButton(
      onPressed: () {
        // Directly modify the static state.
        App.reset = true;
        //App.home = true;
        //Game.reset();
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
      child: const Text('Main Menu', style: TextStyle(fontSize: 20)),
    );
  }

  Widget keepup() {
    return ElevatedButton(
      onPressed: () {
        // Directly modify the static state.
        // The App widget's rebuild mechanism will handle hiding the overlay.
        Game.nextLevel();
        Game.animationController.repeat();
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
      child: const Text('Next Level', style: TextStyle(fontSize: 20)),
    );
  }

  Widget death() {
    return Container(
      color: Colors.red,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'GAME OVER',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 50),
            quit(),
          ],
        ),
      ),
    );
  }

  Widget wintext() {
    // you're a good baby
    // now grow up
    // you grow up so fast
    // keep going
    // you're the boss now
    // you can go back to your life

    return switch (Game.challenge) {
      Challenge.baby => Column(
        children: [
          Text(
            "You're a good baby",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Now grow up",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
      Challenge.normie => Column(
        children: [
          Text(
            "You grow up so fast",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Keep going",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
      Challenge.boss => Column(
        children: [
          Text(
            "You're the boss now",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "You can go back to your life",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    };
    return Column(children: [Text("You're a good baby"), Text("Now grow up")]);
  }

  Widget victory() {
    return Container(
      color: Colors.green,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'VICTORY',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 50),
            Game.level < Level.zones.length - 1 ? Container() : wintext(),
            Game.level < Level.zones.length - 1 ? keepup() : Container(),
            const SizedBox(height: 40),
            quit(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Level.remaining > 0 ? death() : victory();
    //Column(
    //  mainAxisAlignment: MainAxisAlignment.center,
    //  children: [
    //    Text(
    //      Level.remaining > 0 ? 'GAME OVER' : 'VICTORY',
    //      style: const TextStyle(
    //        color: Colors.white,
    //        fontSize: 40,
    //        fontWeight: FontWeight.bold,
    //      ),
    //    ),
    //    const SizedBox(height: 50),
    //Text(
    //  'Final Score: ${Game.score}',
    //  style: const TextStyle(color: Colors.white, fontSize: 24),
    //),
    //Text(
    //  Level.remaining > 0
    //      ? 'ENTER TO RESTART'
    //      : Player.lives > 0
    //      ? Game.level < Level.zones.length - 1
    //          ? 'ENTER NEXT LEVEL'
    //          : 'ENTER TO RESTART'
    //      : 'ENTER TO RESTART',
    //  //: 'ENTER NEXT LEVEL',
    //  style: const TextStyle(
    //    color: Colors.white,
    //    fontSize: 30,
    //    fontWeight: FontWeight.bold,
    //  ),
    //),
    //],
    //),
  }
}
