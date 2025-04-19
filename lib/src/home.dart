import 'package:flutter/material.dart';
import 'package:gunda/src/app.dart';

class Home {
  static bool skip = false;

  static Widget build() {
    return Container(
      color: Colors.teal,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'GUNDA',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                App.home = false;
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
              child: const Text('Start', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
