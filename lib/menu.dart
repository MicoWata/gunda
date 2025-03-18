import 'package:flutter/material.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64 * 16,
      height: 64 * 2,
      child: Container(
        color: Colors.black,
        child: Row(
          children: [
            Flexible(
              flex: 1,
              child: Container(
                color: Colors.black,
                child: Row(
                  children: [
                    SizedBox(width: 64),
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: Container(color: Colors.red),
                    ),
                    SizedBox(width: 64),
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: Container(color: Colors.red),
                    ),
                    SizedBox(width: 64),
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: Container(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: Container(
                color: Colors.black,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: Container(color: Colors.grey),
                    ),
                    SizedBox(width: 64),
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: Container(color: Colors.yellow),
                    ),
                    SizedBox(width: 64),
                  ],
                ),
              ),
            ),
            //Flexible(flex: 1, child: Container(color: Colors.yellow)),
          ],
        ),
      ),
    );
  }
}
