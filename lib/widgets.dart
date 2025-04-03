import 'package:flutter/material.dart';
import 'config.dart';

class GameBackgroundWidget extends StatelessWidget {
  final Color color;

  const GameBackgroundWidget({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color, color.withOpacity(0.0)],
        ),
      ),
    );
  }
}

class PlayerWidget extends StatelessWidget {
  final double playerX, playerY, playerWidth, playerHeight, scaleFactor;
  final Color color;

  const PlayerWidget({
    super.key,
    required this.playerX,
    required this.playerY,
    required this.playerWidth,
    required this.playerHeight,
    required this.scaleFactor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: playerX,
      top: playerY,
      child: Container(
        width: playerWidth,
        height: playerHeight,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(10 * scaleFactor),
          ),
          boxShadow: [
            BoxShadow(
              color: GameColors.shadow.withOpacity(0.4),
              blurRadius: 8 * scaleFactor,
              offset: Offset(0, 4 * scaleFactor),
            ),
          ],
        ),
      ),
    );
  }
}

class BallWidget extends StatelessWidget {
  final double ballX, ballY, ballRadius, scaleFactor;
  final Color color;

  const BallWidget({
    super.key,
    required this.ballX,
    required this.ballY,
    required this.ballRadius,
    required this.scaleFactor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: ballX,
      top: ballY,
      child: Container(
        width: ballRadius * 2,
        height: ballRadius * 2,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: GameColors.shadow.withOpacity(0.3),
              blurRadius: 4 * scaleFactor,
              offset: Offset(0, 2 * scaleFactor),
            ),
          ],
        ),
      ),
    );
  }
}

class StartScreenOverlayWidget extends StatelessWidget {
  final double scaleFactor;
  final VoidCallback onPlayPressed;
  final Color playerColor;
  final Color ballColor;
  final Color accentColor;

  const StartScreenOverlayWidget({
    super.key,
    required this.scaleFactor,
    required this.onPlayPressed,
    required this.playerColor,
    required this.ballColor,
    required this.accentColor,
  });

  Widget _buildStaticTitle(BuildContext context) {
    final baseTitleStyle = TextStyle(
      fontSize: 50 * scaleFactor,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.5 * scaleFactor,
    );
    const double baseStroke = 4.0;
    final double strokeWidth = baseStroke * scaleFactor;

    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          'Volicity',
          style: baseTitleStyle.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeJoin = StrokeJoin.round
              ..strokeCap = StrokeCap.round
              ..strokeWidth = strokeWidth
              ..color = playerColor.withOpacity(0.8),
          ),
        ),
        Text(
          'Volicity',
          style: baseTitleStyle.copyWith(
            color: ballColor,
            shadows: [
              Shadow(
                color: GameColors.shadow.withOpacity(0.5),
                blurRadius: 10 * scaleFactor,
                offset: Offset(0, 2 * scaleFactor),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: playerColor,
        padding: EdgeInsets.symmetric(
            horizontal: 70 * scaleFactor, vertical: 15 * scaleFactor),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30 * scaleFactor)),
        elevation: 8 * scaleFactor,
        shadowColor: accentColor.withOpacity(0.5),
      ),
      onPressed: onPlayPressed,
      child: Text(
        'PLAY',
        style: TextStyle(
          fontSize: 24 * scaleFactor,
          fontWeight: FontWeight.bold,
          color: ballColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: GameColors.startScreenOverlay,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStaticTitle(context),
            SizedBox(height: 60 * scaleFactor),
            _buildPlayButton(context),
            SizedBox(height: 30 * scaleFactor),
            Text('Slide to move player',
                style: TextStyle(
                    fontSize: 16 * scaleFactor, color: Colors.grey[400])),
          ],
        ),
      ),
    );
  }
}

class ScoreDisplayWidget extends StatelessWidget {
  final int score;
  final int highScore;
  final bool isGameActive;
  final double scaleFactor;
  final Color ballColor;
  final Color accentColor;
  final Color highScoreColor;

  const ScoreDisplayWidget({
    super.key,
    required this.score,
    required this.highScore,
    required this.isGameActive,
    required this.scaleFactor,
    required this.ballColor,
    required this.accentColor,
    required this.highScoreColor,
  });

  @override
  Widget build(BuildContext context) {
    final scoreTextStyle = TextStyle(
        fontSize: 18 * scaleFactor,
        fontWeight: FontWeight.bold,
        color: ballColor);
    final scoreIconSize = 18 * scaleFactor;
    final spacing = 4 * scaleFactor;
    final sectionPadding = 12 * scaleFactor;

    return Positioned(
      top: 20 * scaleFactor,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: 15 * scaleFactor, vertical: 8 * scaleFactor),
          decoration: BoxDecoration(
            color: GameColors.shadow.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20 * scaleFactor),
            border: Border.all(
                color: GameColors.subtleBorder, width: 1 * scaleFactor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isGameActive)
                Padding(
                  padding: EdgeInsets.only(right: sectionPadding),
                  child: _ScoreItem(
                    icon: Icons.star_rounded,
                    value: score.toString(),
                    color: accentColor,
                    iconSize: scoreIconSize,
                    textStyle: scoreTextStyle,
                    spacing: spacing,
                  ),
                ),
              _ScoreItem(
                icon: Icons.leaderboard_rounded,
                value: highScore.toString(),
                color: highScoreColor,
                iconSize: scoreIconSize,
                textStyle: scoreTextStyle,
                spacing: spacing,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;
  final double iconSize;
  final TextStyle textStyle;
  final double spacing;

  const _ScoreItem({
    required this.icon,
    required this.value,
    required this.color,
    required this.iconSize,
    required this.textStyle,
    required this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: iconSize),
        SizedBox(width: spacing),
        Text(value, style: textStyle.copyWith(color: color)),
      ],
    );
  }
}
