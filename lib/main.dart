import 'package:flutter/material.dart';
import 'game.dart';
import 'config.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Volicity',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: GameColors.background,
        colorScheme: const ColorScheme.dark(
          primary: GameColors.player,
          secondary: GameColors.accent,
          surface: GameColors.surface,
        ),
      ),
      home: const VolicityGame(), // Start the game
      debugShowCheckedModeBanner: false,
    );
  }
}
