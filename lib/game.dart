import 'package:flutter/material.dart';
import 'dart:math' show Random, min;
import 'config.dart';
import 'widgets.dart';

class VolicityGame extends StatefulWidget {
  final double gravityFactor;
  final double wallBounceDamping;
  final double topWallBounceDamping;
  final double playerBounceVelocityY;
  final double playerBounceVelocityXFactor;
  final double initialBallVelocityY;
  final double maxInitialBallVelocityX;

  const VolicityGame({
    super.key,
    // Default values from config.dart
    this.gravityFactor = defaultGravityFactor,
    this.wallBounceDamping = defaultWallBounceDamping,
    this.topWallBounceDamping = defaultTopWallBounceDamping,
    this.playerBounceVelocityY = defaultPlayerBounceVelocityY,
    this.playerBounceVelocityXFactor = defaultPlayerBounceVelocityXFactor,
    this.initialBallVelocityY = defaultInitialBallVelocityY,
    this.maxInitialBallVelocityX = defaultMaxInitialBallVelocityX,
  });

  @override
  State<VolicityGame> createState() => _VolicityGameState();
}

class _VolicityGameState extends State<VolicityGame>
    with SingleTickerProviderStateMixin {
  // --- Main State ---
  late AnimationController _controller;
  double _scaleFactor = 1.0;
  int _score = 0, _highScore = 0;
  bool _isGameActive = false;

  // --- Player State ---
  double _playerWidth = 0, _playerHeight = 0, _playerX = 0, _playerY = 0;
  double _playerTargetX = 0;

  // --- Ball State ---
  double _ballRadius = 0, _ballX = 0, _ballY = 0, _ballVX = 0, _ballVY = 0;

  // --- Background State ---
  double _backgroundHue = 0.0;
  double _backgroundSaturation = 0.0;

  // --- Scaled Dimensions ---
  double get _gameWidth => baseGameWidth * _scaleFactor;
  double get _gameHeight => baseGameHeight * _scaleFactor;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16), // Target ~60 FPS
    )
      ..addListener(_updateGame)
      ..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-initialize if resize
    _calculateScaleFactor();
    _initializeGameElements();
  }

  // Fit the base game dimensions within the screen, preserving aspect ratio
  void _calculateScaleFactor() {
    final screenSize = MediaQuery.of(context).size;
    _scaleFactor = min(
        screenSize.width / baseGameWidth, screenSize.height / baseGameHeight);
  }

  // Set initial sizes and call reset
  void _initializeGameElements() {
    _playerWidth = basePlayerWidth * _scaleFactor;
    _playerHeight = basePlayerHeight * _scaleFactor;
    _ballRadius = baseBallRadius * _scaleFactor;
    _resetGame();
    if (mounted) {
      setState(() {});
    }
  }

  void _resetGame() {
    _playerX = _gameWidth / 2 - _playerWidth / 2;
    _playerY = _gameHeight * playerYRatio - _playerHeight;
    _playerTargetX = _gameWidth / 2;

    _spawnBall();

    if (_score > _highScore) {
      _highScore = _score;
    }
    _score = 0;
    _isGameActive = false;
    _backgroundSaturation = 0.0;
  }

  void _spawnBall() {
    final random = Random();
    _ballX = random.nextDouble() * (_gameWidth - _ballRadius * 2);
    _ballY = _gameHeight * initialBallYRatio;

    // Apply initial velocity (scaled)
    final maxVelX = widget.maxInitialBallVelocityX * _scaleFactor;
    _ballVX = (random.nextDouble() * 2 * maxVelX) - maxVelX;
    _ballVY = widget.initialBallVelocityY * _scaleFactor;
  }

  // Main game loop, called every frame by the AnimationController
  void _updateGame() {
    // Ignore updates if widget is disposed
    if (!mounted) return;

    // Update game state only if active
    if (_isGameActive) {
      _backgroundHue = (_backgroundHue + 0.5) % 360;
      if (_backgroundSaturation < 0.8) _backgroundSaturation += 0.005;

      // Update player position smoothly towards the input target
      _playerX = (_playerTargetX - _playerWidth / 2)
          .clamp(0, _gameWidth - _playerWidth);

      // Apply physics to ball
      _ballVY += widget.gravityFactor * _scaleFactor;
      _ballX += _ballVX;
      _ballY += _ballVY;

      // Check for collisions
      _handleWallCollisions();
      _handlePlayerCollision();
    }

    // Request redraw
    setState(() {});
  }

  void _handleWallCollisions() {
    // Left/Right Walls
    if (_ballX <= 0) {
      _ballX = 0; // Keep ball within bounds
      _ballVX = _ballVX.abs() *
          widget.wallBounceDamping; // Reverse horizontal velocity with damping
    } else if (_ballX >= _gameWidth - _ballRadius * 2) {
      _ballX = _gameWidth - _ballRadius * 2;
      _ballVX = -_ballVX.abs() * widget.wallBounceDamping;
    }

    // Bottom Wall (Game Over)
    if (_ballY > _gameHeight) {
      _triggerGameOver();
      return;
    }

    // Top Wall
    if (_ballY < 0) {
      _ballY = 0;
      _ballVY = _ballVY.abs() *
          widget.topWallBounceDamping; // Reverse vertical velocity with damping
    }
  }

  void _handlePlayerCollision() {
    final ballRect =
        Rect.fromLTWH(_ballX, _ballY, _ballRadius * 2, _ballRadius * 2);
    final playerRect =
        Rect.fromLTWH(_playerX, _playerY, _playerWidth, _playerHeight);

    // No collision if no overlap or ball moving upwards
    if (!ballRect.overlaps(playerRect) || _ballVY <= 0) {
      return;
    }

    // Narrow phase: More specific check for hitting the top surface of the player
    final ballBottom = _ballY + _ballRadius * 2;
    final ballCenterX = _ballX + _ballRadius;

    // Check if ball's bottom edge is within the player's top surface vertical range
    // and if ball's center is horizontally within the player's bounds
    // Add a small tolerance (+5) and check against ball's velocity to prevent tunneling
    if (ballBottom >= playerRect.top &&
        ballBottom <= playerRect.top + _ballVY.abs() + 5 &&
        ballCenterX >= playerRect.left &&
        ballCenterX <= playerRect.right) {
      // If Collided
      _score++;

      // Calculate horizontal bounce based on hit location on player (0=left, 1=right)
      final hitPositionRatio = (ballCenterX - _playerX) / _playerWidth;
      // Map ratio (-0.5 to 0.5) and apply velocity factor
      _ballVX = (hitPositionRatio - 0.5) *
          widget.playerBounceVelocityXFactor *
          _scaleFactor;

      // Apply standard vertical bounce velocity
      _ballVY = widget.playerBounceVelocityY * _scaleFactor;

      // Position correction: Nudge ball slightly above player to prevent sticking/re-collision
      _ballY = _playerY - _ballRadius * 2 - 1;
    }
  }

  void _triggerGameOver() {
    _resetGame();
    setState(() {});
  }

  Color _getCurrentBackgroundColor() {
    return HSLColor.fromAHSL(1.0, _backgroundHue, _backgroundSaturation, 0.4)
        .toColor();
  }

  // --- Input ---
  void _handleScreenTap(TapDownDetails details) {
    if (!_isGameActive) {
      setState(() {
        _isGameActive = true;
        _backgroundSaturation = 0.0;
      });
    }
    final gamePosition = _getGamePosition(details.globalPosition);
    if (gamePosition != null) _updatePlayerTarget(gamePosition.dx);
  }

  void _handleScreenDrag(DragUpdateDetails details) {
    if (!_isGameActive) return;
    final gamePosition = _getGamePosition(details.globalPosition);
    if (gamePosition != null) _updatePlayerTarget(gamePosition.dx);
  }

  void _handleScreenDragStart(DragStartDetails details) {
    if (!_isGameActive) return;
    final gamePosition = _getGamePosition(details.globalPosition);
    if (gamePosition != null) _updatePlayerTarget(gamePosition.dx);
  }

  Offset? _getGamePosition(Offset globalPosition) {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;

    // Convert global point to local coordinates within the RenderBox
    final Offset localPosition = renderBox.globalToLocal(globalPosition);

    // Account for the centering of the game area (SizedBox) within the RenderBox
    final double totalScreenWidth = renderBox.size.width;
    final double centeringOffsetX = (totalScreenWidth - _gameWidth) / 2;

    // Calculate position relative to the top-left of the game area
    final double gameX = localPosition.dx - centeringOffsetX;
    final double gameY = localPosition.dy;

    return Offset(gameX, gameY);
  }

  void _updatePlayerTarget(double touchX) {
    setState(() {
      _playerTargetX = touchX.clamp(0, _gameWidth);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTapDown: _handleScreenTap,
        onPanUpdate: _handleScreenDrag,
        onPanStart: _handleScreenDragStart,
        child: Container(
          color: GameColors.background,
          child: Center(
            child: SizedBox(
              width: _gameWidth,
              height: _gameHeight,
              child: ClipRect(
                child: Stack(
                  children: [
                    GameBackgroundWidget(color: _getCurrentBackgroundColor()),

                    PlayerWidget(
                      playerX: _playerX,
                      playerY: _playerY,
                      playerWidth: _playerWidth,
                      playerHeight: _playerHeight,
                      scaleFactor: _scaleFactor,
                      color: GameColors.player,
                    ),

                    BallWidget(
                      ballX: _ballX,
                      ballY: _ballY,
                      ballRadius: _ballRadius,
                      scaleFactor: _scaleFactor,
                      color: GameColors.ball,
                    ),

                    // Start Screen Overlay
                    if (!_isGameActive)
                      StartScreenOverlayWidget(
                        scaleFactor: _scaleFactor,
                        onPlayPressed: () {
                          // Play button action
                          if (mounted) {
                            setState(() {
                              _isGameActive = true;
                              _backgroundSaturation = 0.0;
                            });
                          }
                        },
                        playerColor: GameColors.player,
                        ballColor: GameColors.ball,
                        accentColor: GameColors.accent,
                      ),

                    ScoreDisplayWidget(
                      score: _score,
                      highScore: _highScore,
                      isGameActive: _isGameActive,
                      scaleFactor: _scaleFactor,
                      ballColor: GameColors.ball,
                      accentColor: GameColors.accent,
                      highScoreColor: GameColors.highScore,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
