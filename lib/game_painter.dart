import 'package:flutter/material.dart';
import 'models.dart';

class GamePainter extends CustomPainter {
  final PlayerCar playerCar;
  final List<Obstacle> obstacles;
  final double roadPadding;

  GamePainter({
    required this.playerCar,
    required this.obstacles,
    required this.roadPadding,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // --- Draw Road ---
    final roadPaint = Paint()..color = Colors.grey[800]!;
    final roadWidth = size.width - (2 * roadPadding);
    canvas.drawRect(
        Rect.fromLTWH(roadPadding, 0, roadWidth, size.height), roadPaint);

    // --- Draw Road Markings (Optional Dashed Lines) ---
    final linePaint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 5;
    const double dashHeight = 20.0;
    const double dashSpace = 15.0;
    double currentY = 0;
    // Calculate center line position
    final centerLineX = roadPadding + roadWidth / 2;
    while (currentY < size.height) {
      canvas.drawLine(
        Offset(centerLineX, currentY),
        Offset(centerLineX, currentY + dashHeight),
        linePaint,
      );
      currentY += dashHeight + dashSpace;
    }

    // --- Draw Player Car ---
    final playerPaint = Paint()..color = Colors.blue;
    Rect playerRect = Rect.fromLTWH(
      playerCar.position.dx,
      playerCar.position.dy,
      playerCar.size.width,
      playerCar.size.height,
    );
    // Simple rectangle for the car body
    canvas.drawRect(playerRect, playerPaint);
    // Add some detail (e.g., windshield)
    final windshieldPaint = Paint()..color = Colors.lightBlueAccent;
    Rect windshieldRect = Rect.fromLTWH(
      playerCar.position.dx + 5,
      playerCar.position.dy + 10,
      playerCar.size.width - 10,
      playerCar.size.height * 0.3,
    );
    canvas.drawRect(windshieldRect, windshieldPaint);

    // --- Draw Obstacles ---
    final obstaclePaint = Paint()..color = Colors.red;
    for (final obstacle in obstacles) {
      Rect obstacleRect = Rect.fromLTWH(
        obstacle.position.dx,
        obstacle.position.dy,
        obstacle.size.width,
        obstacle.size.height,
      );
      canvas.drawRect(obstacleRect, obstaclePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Repaint whenever the game state changes
    return true;
  }
}
