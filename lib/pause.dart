import 'package:flutter/material.dart';

final modalKey = GlobalKey<_PauseState>();

class Pause extends StatefulWidget {
  const Pause({super.key});

  @override
  _PauseState createState() => _PauseState();
}

class _PauseState extends State<Pause> {
  bool _isVisible = false;

  void toggle() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          //Center(
          //  child: ElevatedButton(
          //    onPressed: toggleModal,
          //    child: Text(_isVisible ? 'Hide Modal' : 'Show Modal'),
          //  ),
          //),
          // The modal container
          if (_isVisible)
            SizedBox(
              width: 64 * 6,
              height: 64 * 8,
              child: Container(
                color: Colors.cyan,
                child: Center(
                  child: SizedBox(
                    width: 64 * 5,
                    height: 64 * 7,
                    child: Container(
                      color: Colors.green,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Flexible(flex: 1, child: Text('Continue')),
                          Flexible(flex: 1, child: Text('Options')),
                          Flexible(flex: 1, child: Text('Exit')),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          //GestureDetector(
          //  onTap: toggle, // Close when tapping outside
          //  child: Container(
          //    color: Colors.black54, // Semi-transparent background
          //    alignment: Alignment.center,
          //    child: GestureDetector(
          //      onTap: () {}, // Prevent closing when tapping modal itself
          //      child: Container(
          //        margin: EdgeInsets.all(20),
          //        padding: EdgeInsets.all(20),
          //        decoration: BoxDecoration(
          //          color: Colors.white,
          //          borderRadius: BorderRadius.circular(10),
          //        ),
          //        width: 800,
          //        child: Column(
          //          mainAxisSize: MainAxisSize.min,
          //          children: [
          //            Text('Custom Modal', style: TextStyle(fontSize: 20)),
          //            SizedBox(height: 20),
          //            Text('This is a custom modal container'),
          //            SizedBox(height: 20),
          //            //ElevatedButton(
          //            //  onPressed: toggleModal,
          //            //  child: Text('Close'),
          //            //),
          //          ],
          //        ),
          //      ),
          //    ),
          //  ),
          //),
        ],
      ),
    );
  }
}
