import 'values.dart';

class Piece {
  Tetromino type;

  Piece({required this.type});

  // the piece is just a list of integers
  List<int> position = [];

  void initializePiece() {
    switch (type) {
      case Tetromino.L:
        position = [
          4, 
          14, 
          24, 
          25,
          ];
        break;
      default:
    }
  }
}
