import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'game_painter.dart';
import 'models.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const double _playerCarWidth = 50.0;
  static const double _playerCarHeight = 80.0;
  static const double _obstacleWidth = 50.0;
  static const double _obstacleHeight = 50.0;
  static const double _roadPadding = 30.0; // Padding from screen edges
  static const double _initialPlayerSpeed = 3.0;
  static const double _initialObstacleSpeed = 4.0;
  static const int _initialSpawnRateMs = 1500; // Milliseconds

  late Size _screenSize;
  late double _roadWidth;
  late PlayerCar _playerCar;
  final List<Obstacle> _obstacles = [];
  double _playerSpeed = _initialPlayerSpeed;
  double _obstacleSpeed = _initialObstacleSpeed;
  int _spawnRateMs = _initialSpawnRateMs;
  int _score = 0;
  bool _isGameOver = false;
  Timer? _gameLoopTimer;
  Timer? _obstacleSpawnTimer;
  final Random _random = Random();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize sizes and positions here where context is available
    _screenSize = MediaQuery.of(context).size;
    _roadWidth = _screenSize.width - (2 * _roadPadding);
    _initializeGame();
  }

  void _initializeGame() {
    _playerCar = PlayerCar(
      position: Offset(
        _screenSize.width / 2 - _playerCarWidth / 2, // Center horizontally
        _screenSize.height - _playerCarHeight - 50, // Near bottom
      ),
      size: const Size(_playerCarWidth, _playerCarHeight),
    );
    _obstacles.clear();
    _score = 0;
    _isGameOver = false;
    _playerSpeed = _initialPlayerSpeed;
    _obstacleSpeed = _initialObstacleSpeed;
    _spawnRateMs = _initialSpawnRateMs;
    _startGameLoop();
    _startObstacleSpawning();
  }

  void _startGameLoop() {
    _gameLoopTimer?.cancel(); // Cancel any existing timer
    _gameLoopTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!_isGameOver) {
        _updateGame();
      } else {
        timer.cancel(); // Stop the timer if game over
        _obstacleSpawnTimer?.cancel();
      }
    });
  }

  void _startObstacleSpawning() {
    _obstacleSpawnTimer?.cancel();
    _obstacleSpawnTimer =
        Timer.periodic(Duration(milliseconds: _spawnRateMs), (timer) {
      if (!_isGameOver) {
        _spawnObstacle();
        // Gradually increase difficulty
        if (_spawnRateMs > 500) _spawnRateMs -= 50;
        _obstacleSpeed += 0.1;
      } else {
        timer.cancel();
      }
    });
  }

  void _spawnObstacle() {
    // Ensure obstacles spawn within the road boundaries
    double randomX =
        _roadPadding + _random.nextDouble() * (_roadWidth - _obstacleWidth);
    setState(() {
      _obstacles.add(
        Obstacle(
          position: Offset(randomX, -_obstacleHeight), // Start above screen
          size: const Size(_obstacleWidth, _obstacleHeight),
        ),
      );
    });
  }

  void _updateGame() {
    setState(() {
      // Move obstacles
      for (int i = _obstacles.length - 1; i >= 0; i--) {
        _obstacles[i].position =
            _obstacles[i].position.translate(0, _obstacleSpeed);
        // Remove obstacles that have gone off screen
        if (_obstacles[i].position.dy > _screenSize.height) {
          _obstacles.removeAt(i);
          _score++; // Increment score when obstacle is passed
        }
      }

      // Check for collisions
      Rect playerRect = Rect.fromLTWH(
        _playerCar.position.dx,
        _playerCar.position.dy,
        _playerCar.size.width,
        _playerCar.size.height,
      );

      for (Obstacle obstacle in _obstacles) {
        Rect obstacleRect = Rect.fromLTWH(
          obstacle.position.dx,
          obstacle.position.dy,
          obstacle.size.width,
          obstacle.size.height,
        );
        if (playerRect.overlaps(obstacleRect)) {
          _gameOver();
          break;
        }
      }
    });
  }

  void _movePlayer(double dx) {
    if (_isGameOver) return;

    setState(() {
      double newX = _playerCar.position.dx + dx;
      // Clamp player position within road boundaries
      newX = newX.clamp(_roadPadding,
          _screenSize.width - _roadPadding - _playerCar.size.width);
      _playerCar.position = Offset(newX, _playerCar.position.dy);
    });
  }

  void _gameOver() {
    setState(() {
      _isGameOver = true;
    });
    _gameLoopTimer?.cancel();
    _obstacleSpawnTimer?.cancel();
  }

  void _restartGame() {
    _initializeGame();
  }

  @override
  void dispose() {
    _gameLoopTimer?.cancel();
    _obstacleSpawnTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure screen size is available before building
    if (_screenSize == Size.zero) {
      // This might happen briefly on the first frame
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          // Adjust sensitivity if needed
          _movePlayer(details.delta.dx * 1.5);
        },
        // Alternative: Tap to move left/right
        // onTapDown: (details) {
        //   if (details.globalPosition.dx < _screenSize.width / 2) {
        //     _movePlayer(-_playerSpeed * 10); // Move left
        //   } else {
        //     _movePlayer(_playerSpeed * 10); // Move right
        //   }
        // },
        child: Stack(
          children: [
            // Game rendering area
            CustomPaint(
              size: _screenSize,
              painter: GamePainter(
                playerCar: _playerCar,
                obstacles: _obstacles,
                roadPadding: _roadPadding,
              ),
            ),
            // Score display
            Positioned(
              top: 40,
              left: 20,
              child: Text(
                'Score: $_score',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            // Game Over overlay
            if (_isGameOver)
              Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Game Over',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Final Score: $_score',
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: _restartGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                        ),
                        child: const Text(
                          'Restart',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
