import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tetris_app/piece.dart';
import 'package:tetris_app/values.dart';
import 'pixel.dart';

List<List<Tetromino?>> gameBoard = List.generate(
  colLength,
  (i) => List.generate(
    rowLength,
    (j) => null,
  ),
);

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  Piece currentPiece = Piece(type: Tetromino.L);

  int currentScore = 0;

  bool gameOver = false;

  @override
  void initState() {
    super.initState();
    // Initialize the game board with empty cells.
    startGame();
  }

  void startGame() {
    currentPiece.initializePiece();

    Duration frameRate = const Duration(milliseconds: 800);
    gameLoop(frameRate);
  }

  void gameLoop(Duration frameRate) {
    Timer.periodic(
      frameRate,
      (timer) {
        setState(() {
          clearLines();
          checkLanding();

          if (gameOver == true) {
            timer.cancel();
            showGameOverDialog();
          }
          currentPiece.movePiece(Direction.down);
        });
      },
    );
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Game Over'),
        content: Text('Your Score: $currentScore'),
        actions: [
          TextButton(
            onPressed: () {
              resetGame();
              Navigator.pop(context);
            },
            child: Text('Play Again'),
          ),
        ],
      ),
    );
  }

  void resetGame() {
    gameBoard = List.generate(
      colLength,
      (i) => List.generate(
        rowLength,
        (j) => null,
      ),
    );

    gameOver = false;
    currentScore = 0;

    createNewPiece();

    startGame();
  }

  bool checkCollision(Direction direction) {
    for (int i = 0; i < currentPiece.position.length; i++) {
      //calculate the row and collision
      int row = (currentPiece.position[i] / rowLength).floor();
      int col = currentPiece.position[i] % rowLength;

      if (direction == Direction.left) {
        col -= 1;
      } else if (direction == Direction.right) {
        col += 1;
      } else if (direction == Direction.down) {
        row += 1;
      }

      // check if the piece is out of bounds (either too low or too far to the left or right)
      if (row >= colLength ||
          col < 0 ||
          col >= rowLength ||
          (row >= 0 && gameBoard[row][col] != null)) {
        return true;
      }
    }

    // if no collision detected, return false
    return false;
  }

  void checkLanding() {
    if (checkCollision(Direction.down)) {
      for (int i = 0; i < currentPiece.position.length; i++) {
        int row = (currentPiece.position[i] / rowLength).floor();
        int col = currentPiece.position[i] % rowLength;

        if (row >= 0 && col >= 0) {
          gameBoard[row][col] = currentPiece.type;
        }
      }
      createNewPiece();
    }
  }

  // is something like checking collision, but for
  bool canMove(Piece piece, int x, int y) {
    for (int pos in piece.position) {
      int row = (pos / rowLength).floor();
      int col = pos % rowLength;

      row += y;
      col += x;

      if (row >= colLength ||
          col < 0 ||
          col >= rowLength ||
          (row >= 0 && gameBoard[row][col] != null)) {
        return false;
      }
    }
    return true;
  }

  void createNewPiece() {
    Random rand = Random();
    Tetromino randomType =
        Tetromino.values[rand.nextInt(Tetromino.values.length)];
    currentPiece = Piece(type: randomType);
    currentPiece.initializePiece();

    if (isGameOver()) {
      gameOver = true;
    }
  }

  // Once the hard drop is done the piece is locked
  void lockPiece() {
    for (int i = 0; i < currentPiece.position.length; i++) {
      int row = (currentPiece.position[i] / rowLength).floor();
      int col = currentPiece.position[i] % rowLength;
      if (row >= 0 && col >= 0) {
        gameBoard[row][col] = currentPiece.type;
      }
    }
  }

  // Movement see piece.dart for more information
  void moveLeft() {
    if (!checkCollision(Direction.left)) {
      setState(() {
        currentPiece.movePiece(Direction.left);
      });
    }
  }

  void moveRight() {
    if (!checkCollision(Direction.right)) {
      setState(() {
        currentPiece.movePiece(Direction.right);
      });
    }
  }

  void moveDown() {
    if (!checkCollision(Direction.down)) {
      setState(() {
        currentPiece.movePiece(Direction.down);
      });
    }
  }

  void hardDrop() {
    setState(() {
      while (canMove(currentPiece, 0, 1)) {
         // Move the piece down by one row
        currentPiece.movePiece(Direction.down);
      }
      lockPiece();
      clearLines();
      createNewPiece();
    });
  }

  void rotatePiece() {
    setState(() {
      currentPiece.rotatePiece();
    });
  }

  void clearLines() {
    List<int> fullRows = [];

    for (int row = 0; row < colLength; row++) {
      if (gameBoard[row].every((cell) => cell != null)) {
        fullRows.add(row);
      }
    }

    if (fullRows.isNotEmpty) {
      setState(() {
        // Remove full rows from the game board and move remaining rows up
        for (int row in fullRows) {
          for (int r = row; r > 0; r--) {
            gameBoard[r] = List.from(gameBoard[r - 1]);
          }
          // Add a new empty row at the top
          gameBoard[0] = List.generate(rowLength, (index) => null);
        }

        int baseScore = 100;
        int linesCleared = fullRows.length;

        // Apply multiplier based on lines cleared
        double multiplier = 1.0;
        if (linesCleared == 2) {
          multiplier = 1.10; // 10%
        } else if (linesCleared == 3) {
          multiplier = 1.15; // 15%
        } else if (linesCleared == 4) {
          multiplier = 1.5; // 50%
        }

        // This is 100 * linesClrared (can be 1-4) * multiplier if only one line, just 100 * 1 * 1
        // One line 100 * 1 * 1 = 100 
        // Two lines 100 * 2 * 1.10 = 220
        // Three lines 100 * 3 * 1.15 = 345
        // Four lines 100 * 4 * 1.5 = 600
        currentScore += (baseScore * linesCleared * multiplier).toInt();
      });
    }
  }

  bool isGameOver() {
    for (int col = 0; col < rowLength; col++) {
      if (gameBoard[0][col] != null) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              itemCount: rowLength * colLength,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: rowLength),
              itemBuilder: (context, index) {
                int row = (index / rowLength).floor();
                int col = index % rowLength;
                if (currentPiece.position.contains(index)) {
                  return Pixel(color: currentPiece.color);
                } else if (gameBoard[row][col] != null) {
                  final Tetromino? tetrominoType = gameBoard[row][col];
                  return Pixel(color: tetrominoColors[tetrominoType]);
                } else {
                  return Pixel(color: Colors.grey[900]);
                }
              },
            ),
          ),
          Text(
            'Score: $currentScore',
            style: TextStyle(color: Colors.white),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Left side controls
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: moveLeft,
                          color: Colors.white,
                          icon: Icon(Icons.arrow_left),
                          highlightColor: Colors.amberAccent,
                        ),
                        IconButton(
                          onPressed: moveRight,
                          color: Colors.white,
                          icon: Icon(Icons.arrow_right),
                          highlightColor: Colors.amberAccent,
                        ),
                      ],
                    ),
                    // Move down button centered below left and right buttons
                    IconButton(
                      onPressed: moveDown,
                      color: Colors.white,
                      icon: Icon(Icons.arrow_drop_down),
                      highlightColor: Colors.amberAccent,
                    ),
                  ],
                ),

                // Right side controls
                Row(
                  children: [
                    IconButton(
                      onPressed: rotatePiece,
                      color: Colors.white,
                      icon: Icon(Icons.rotate_right),
                      highlightColor: Colors.amberAccent,
                    ),
                    IconButton(
                      onPressed: hardDrop,
                      icon: Icon(Icons.arrow_circle_down),
                      color: Colors.white,
                      highlightColor: Colors.amberAccent,
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
