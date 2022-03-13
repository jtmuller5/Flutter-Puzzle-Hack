import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:puzzle/models/puzzle_piece.dart';
import 'package:puzzle/services/services.dart';
import 'package:stacked/stacked.dart';

@lazySingleton
class PuzzleService with ReactiveServiceMixin {
  dynamic imageBytes;

  double sideLength = 50;
  double puzzlePadding = kIsWeb ? 200 : 100;
  double maxSideLength = 500;
  int sideCount = 3;
  final double sensitivity = 1;
  int totalMoves = 0;
  int totalSwaps = 0;

  List<PuzzlePiece> pieces = [];
  List<Offset> targets = [];
  List<Offset> startingPositions = [];
  List<Uint8List> images = [];

  bool get puzzleSolved {
    bool solved = true;

    if (pieces.isEmpty) return false;

    pieces.forEach((piece) {
      if (!piece.onTarget) {
        solved = false;
      }
    });

    return solved;
  }

  void clearPuzzle() {
    imageBytes = null;
    pieces = [];
    puzzleStarted = false;
    notifyListeners();
  }

  void setImageBytes(Uint8List? val) {
    imageBytes = val;
    notifyListeners();
  }

  void setSideLength(double val) {
    sideLength = val;
    notifyListeners();
  }

  void incrementMoves() {
    totalMoves++;

    if (!(timerService.stopwatch.isRunning)) {
      timerService.startStopwatch();
    }

    notifyListeners();
  }

  void incrementSwaps() {
    totalSwaps++;

    if (!(timerService.stopwatch.isRunning)) {
      timerService.startStopwatch();
    }

    notifyListeners();
  }

  void restart() {
    totalMoves = 0;
    totalSwaps = 0;
    timerService.stopwatch.stop();
    timerService.stopwatch.reset();
  }

  double getSideLength(BuildContext context) {
    double side = MediaQuery.of(context).size.shortestSide - puzzlePadding;

    if (side > maxSideLength) {
      return roundToVal(maxSideLength / sideCount, 2);
    } else {
      return roundToVal(side / sideCount, 2);
    }
  }

  double roundToVal(double input, double rounder) {
    return (input / rounder).round() * rounder;
  }

  bool puzzleStarted = false;

  void startPuzzle() {
    puzzleStarted = true;
    notifyListeners();
  }

  void getStartingPositions() {
    targets = getOffsetList();

    startingPositions = List.from(targets);

    startingPositions.shuffle();

    for (int x = 0; x < (sideCount * sideCount) - 1; x++) {
      pieces.add(
        PuzzlePiece(
            id: x, pos: startingPositions[x], target: targets[x], empty: false, color: Colors.purple, active: false, image: puzzleService.images[x]),
      );
    }
  }

  void setStartingPositions(List<Offset> val) {
    startingPositions = val;
    notifyListeners();
  }

  List<Offset> getOffsetList() {
    int row = 0;
    int col = 0;

    List<Offset> offsets = [];
    for (int x = 0; x < (sideCount * sideCount) - 1; x++) {
      offsets.add(Offset(col * sideLength, row * sideLength));

      if ((x + 1) % sideCount == 0) {
        row++;
      }

      if (col == sideCount - 1) {
        col = 0;
      } else {
        col++;
      }
    }

    return offsets;
  }
}
