import 'package:flutter/material.dart';

// --- Main Game Dimensions & Ratios ---
// Base width before scaling
const double baseGameWidth = 400;

// Base height before scaling
const double baseGameHeight = 600;

// Ball's initial Y position (fraction of game height)
const double initialBallYRatio = 0.3;

// Player's Y position (fraction of game height)
const double playerYRatio = 7 / 8;

// Default player width before scaling
const double basePlayerWidth = 100;

// Default player height before scaling
const double basePlayerHeight = 20;

// Default ball radius before scaling
const double baseBallRadius = 15;

// --- Default Physics Parameters ---
// Can be overridden via VolicityGame constructor
// Gravity effect multiplier
const double defaultGravityFactor = 0.3;

// Energy retained after side wall collision (0-1)
const double defaultWallBounceDamping = 0.95;

// Energy retained after top wall collision (0-1)
const double defaultTopWallBounceDamping = 0.8;

// Base upward velocity on player hit
const double defaultPlayerBounceVelocityY = -8.0;

// Influence of hit location on horizontal player bounce
const double defaultPlayerBounceVelocityXFactor = 8.0;

// Initial downward velocity of the ball
const double defaultInitialBallVelocityY = -6.0;

// Max magnitude of initial horizontal velocity
const double defaultMaxInitialBallVelocityX = 2.0;

// --- Game Color Palette ---
class GameColors {
  static const Color background = Colors.black;
  static const Color surface = Color(0xFF121212);
  static const Color player = Colors.blueGrey;
  static const Color ball = Colors.white;
  static const Color accent = Colors.amber; // Score color
  static const Color highScore = Colors.lightBlue;
  static const Color startScreenOverlay = Color.fromRGBO(0, 0, 0, 0.75);
  static const Color shadow = Color.fromRGBO(0, 0, 0, 0.4);
  static const Color subtleBorder = Color.fromRGBO(255, 255, 255, 0.2);
}
