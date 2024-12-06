import 'package:flutter/material.dart';
import 'screens/game_screen.dart';

void main() {
  runApp(UnoGame());
}

class UnoGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UNO Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GameScreen(),
    );
  }
}
