import 'package:flutter/material.dart';

// Base class for game objects (optional, but good practice)
abstract class GameObject {
  Offset position;
  Size size;

  GameObject({required this.position, required this.size});

  Rect get rect =>
      Rect.fromLTWH(position.dx, position.dy, size.width, size.height);
}

// Player's car
class PlayerCar extends GameObject {
  PlayerCar({required super.position, required super.size});
}

// Obstacle car/object
class Obstacle extends GameObject {
  Obstacle({required super.position, required super.size});
}
