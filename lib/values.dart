import 'dart:ui';

int rowLength = 10;
int colLength = 15;

enum Direction { left, right, down }

enum Tetromino {
  L,
  J,
  I,
  O,
  S,
  Z,
  T,
}

const Map<Tetromino, Color> tetrominoColors = {
  Tetromino.L: Color(0xFFFFA500), // Orange
  Tetromino.J: Color(0xFF1E90FF), // Dodger Blue
  Tetromino.I: Color(0xFF00FFFF), // Cyan
  Tetromino.O: Color(0xFFFF1493), // Deep Pink 
  Tetromino.S: Color(0xFF32CD32), // Lime Green
  Tetromino.Z: Color(0xFFFF0000), // Red
  Tetromino.T: Color(0xFF800080), // Purple
};
