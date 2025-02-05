import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tetris_app/piece.dart';
import 'package:tetris_app/values.dart';
import 'pixel.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  //grid dimensions
  int rowLength = 10;
  int colLength = 15;

  Piece currentPiece = Piece(type: Tetromino.T);

  @override
  void initState() {
    super.initState();
    // Initialize the game board with empty cells.
    startGame();
  }

  void startGame() {
    currentPiece.initializePiece();

    Duration frameRate = const Duration(milliseconds: 200);
    gameLoop(frameRate);
  }

  void gameLoop(Duration frameRate) {
    Timer.periodic(
      frameRate,
      (timer) {
        setState(() {
          currentPiece.movePiece(Direction.down);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GridView.builder(
        itemCount: rowLength * colLength,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: rowLength),
        itemBuilder: (context, index) {
          if (currentPiece.position.contains(index)) {
            return Pixel(color: Colors.yellow, child: index);
          } else {
            return Pixel(color: Colors.grey[900], child: index);
          }
        },
      ),
    );
  }
}
