import 'dart:math';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:puzzle/models/puzzle_piece.dart';
import 'package:puzzle/services/services.dart';
import 'package:rive/rive.dart';
import 'package:stacked/stacked.dart';
import 'package:universal_io/io.dart';

class HomeViewModel extends ReactiveViewModel {
  SimpleAnimation sunAnimation = SimpleAnimation('Sun');
  SimpleAnimation moonAnimation = SimpleAnimation('Moon');
  SimpleAnimation cloudsAnimation = SimpleAnimation('Clouds');

  StateMachineController? ufoController;
  StateMachineController? cowController;

  SMITrigger? spinRight;
  SMITrigger? spinLeft;
  SMITrigger? pulse;
  SMITrigger? attract;
  SMITrigger? jump;

  bool swapMode = false;
  PuzzlePiece? swapPiece1;
  PuzzlePiece? swapPiece2;

  double get sideLength {
    return puzzleService.sideLength;
  }

  double get puzzlePadding {
    return puzzleService.puzzlePadding;
  }

  int get sideCount {
    return puzzleService.sideCount;
  }

  double get sensitivity {
    return puzzleService.sensitivity;
  }

  List<PuzzlePiece> get pieces {
    return puzzleService.pieces;
  }

  List<Offset> get targets {
    return puzzleService.targets;
  }

  List<Offset> get startingPositions {
    return puzzleService.startingPositions;
  }

  PuzzlePiece? activePiece;

  HomeViewModel(BuildContext context) {
    puzzleService.setSideLength(puzzleService.getSideLength(context));
  }

  Map<int, double> rowTotals = {};
  Map<int, double> columnTotals = {};

  String? dragUpdate;

  void toggleSwapMode() {
    swapMode = !swapMode;

    if(swapMode == false){
      swapPiece1 = null;
      swapPiece2 = null;
    }

    notifyListeners();
  }

  void swapPiece(PuzzlePiece piece) {
    if (swapPiece1 == null) {
      swapPiece1 = piece;
      notifyListeners();
      return;
    }

    if(swapPiece1?.id == piece.id){
      swapPiece1 = null;
      notifyListeners();
      return;
    }

    if (swapPiece2 == null) {
      swapPiece2 = piece;

      Offset firstPos = swapPiece1!.pos;
      Offset secondPos = swapPiece2!.pos;

      swapPiece1!.pos = secondPos;
      swapPiece2!.pos = firstPos;

      puzzleService.incrementSwaps();
      pulse?.fire();
      jump?.fire();

      notifyListeners();

      swapPiece1 = null;
      swapPiece2 = null;

      notifyListeners();
    }
  }

  void setCowMachine(Artboard artboard) {
    if (cowController == null) {
      cowController = StateMachineController.fromArtboard(artboard, 'Cow');
      artboard.addController(cowController!);
      jump = cowController!.findInput<bool>('Jump') as SMITrigger;
      notifyListeners();
    }
  }

  void setStateMachine(Artboard artboard) {
    if (ufoController == null) {
      ufoController = StateMachineController.fromArtboard(artboard, 'optimized');
      artboard.addController(ufoController!);
      spinRight = ufoController!.findInput<bool>('Right') as SMITrigger;
      spinLeft = ufoController!.findInput<bool>('Left') as SMITrigger;
      pulse = ufoController!.findInput<bool>('Pulse') as SMITrigger;
      attract = ufoController!.findInput<bool>('Attract') as SMITrigger;
      notifyListeners();
    }
  }

  void startPuzzle() {
    puzzleService.getStartingPositions();
    puzzleService.startPuzzle();
  }

  void setPieceImage(PuzzlePiece piece, Uint8List image) {
    piece.image = image;
  }

  void setActivePiece(PuzzlePiece? piece) {
    activePiece = piece;
    debugPrint('Setting active piece: $piece');
    notifyListeners();
  }

  double getNearestSnap(double val) {
    return puzzleService.roundToVal(val, sideLength);
  }

  bool keyMovement(MoveDirection direction) {
    debugPrint('trying move');
    bool moved = false;

    List<PuzzlePiece> sortedPieces = List.from(pieces);

    if (direction == MoveDirection.up || direction == MoveDirection.down) {
      sortedPieces.sort((a, b) => a.y.compareTo(b.y));

      if (!direction.positive) sortedPieces = sortedPieces.reversed.toList();
      sortedPieces.forEach((piece) {
        if (!moved) {
          moved = moveVertically(piece, sideLength * (direction.positive ? 1 : -1), animate: true);
        }
      });
    } else {
      sortedPieces.sort((a, b) => a.x.compareTo(b.x));

      if (!direction.positive) sortedPieces = sortedPieces.reversed.toList();
      sortedPieces.forEach((piece) {
        if (!moved) {
          moved = moveHorizontally(piece, sideLength * (direction.positive ? 1 : -1));
        }
      });
    }

    notifyListeners();

    return moved;
  }

  bool moveHorizontally(PuzzlePiece piece, double dx, {bool tapped = false}) {
    /// Positive movement (right)
    if (dx > 0) {
      // Not all the way right
      double limit = getHorizLimit(piece, false);
      if (piece.x < (limit - (dx * sensitivity).abs())) {
        //spinLeft?.fire();
        setActivePiece(piece);
        piece.pos = Offset(piece.x + (dx * sensitivity), piece.y);
        return true;
      } else {
        if (piece.x == limit) {
          //if(tapped) spinLeft?.fire();
          return false;
        } else {
          if (tapped) spinLeft?.fire();
          setActivePiece(piece);
          piece.pos = Offset(limit, piece.y);
          puzzleService.incrementMoves();
          return true;
        }
      }
    }

    /// Negative movement (left)
    else {
      double limit = getHorizLimit(piece, true);
      if (piece.x > (limit + (dx * sensitivity).abs())) {
        //spinRight?.fire();
        setActivePiece(piece);
        piece.pos = Offset(piece.x + (dx * sensitivity), piece.y);
        return true;
      } else {
        if (piece.x == limit) {
          if (tapped) spinRight?.fire();
          return false;
        } else {
          if (tapped) spinRight?.fire();
          setActivePiece(piece);
          piece.pos = Offset(limit, piece.y);
          puzzleService.incrementMoves();
          return true;
        }
      }
    }
  }

  bool moveVertically(PuzzlePiece piece, double dy, {bool animate = false, bool tapped = false}) {
    /// Positive movement (down)
    if (dy > 0) {
      // Not all the way down
      double limit = getVertLimit(piece, false);
      if (piece.y < (limit - (dy * sensitivity).abs())) {
        if (animate) pulse?.fire();
        setActivePiece(piece);
        piece.pos = Offset(piece.x, piece.y + (dy * sensitivity));
        return true;
      } else {
        if (piece.y == limit) {
          if (!tapped) pulse?.fire();
          return false;
        } else {
          if (animate) pulse?.fire();
          setActivePiece(piece);
          piece.pos = Offset(piece.x, limit);
          puzzleService.incrementMoves();
          return true;
        }
      }
    }

    /// Negative movement (up)
    else {
      double limit = getVertLimit(piece, true);
      if (piece.y > (limit + (dy * sensitivity).abs())) {
        if (animate) attract?.fire();
        setActivePiece(piece);
        piece.pos = Offset(piece.x, piece.y + (dy * sensitivity));
        return true;
      } else {
        if (piece.y == limit) {
          if (!tapped) attract?.fire();
          return false;
        } else {
          if (animate) attract?.fire();
          setActivePiece(piece);
          piece.pos = Offset(piece.x, limit);
          puzzleService.incrementMoves();
          return true;
        }
      }
    }
  }

  double getHorizLimit(PuzzlePiece piece, bool lower) {
    if (lower) {
      List<PuzzlePiece> piecesInRows = pieces
          .where((element) =>
              (element.hashCode != piece.hashCode && element.x <= piece.x && (element.y < piece.y + sideLength && element.y > piece.y - sideLength)))
          .toList();

      if (piecesInRows.isNotEmpty) {
        double limit = piecesInRows.map((e) => e.x).toList().reduce(max) + sideLength;
        return limit;
      } else {
        return 0;
      }
    } else {
      List<PuzzlePiece> piecesInRows = pieces
          .where((element) =>
              (element.hashCode != piece.hashCode && element.x >= piece.x && (element.y < piece.y + sideLength && element.y > piece.y - sideLength)))
          .toList();

      if (piecesInRows.isNotEmpty) {
        double limit = piecesInRows.map((e) => e.x).toList().reduce(min) - sideLength;
        return limit;
      } else {
        return sideLength * (sideCount - 1);
      }
    }
  }

  double getVertLimit(PuzzlePiece piece, bool lower) {
    if (lower) {
      List<PuzzlePiece> piecesInCols = pieces
          .where((element) =>
              (element.hashCode != piece.hashCode && element.y <= piece.y && (element.x < piece.x + sideLength && element.x > piece.x - sideLength)))
          .toList();

      if (piecesInCols.isNotEmpty) {
        double limit = piecesInCols.map((e) => e.y).toList().reduce(max) + sideLength;
        return limit;
      } else {
        return 0;
      }
    } else {
      List<PuzzlePiece> piecesInCols = pieces
          .where((element) => (element.hashCode != piece.hashCode &&
              element.y >= (piece.y + sideLength) &&
              (element.x < piece.x + sideLength && element.x > piece.x - sideLength)))
          .toList();

      if (piecesInCols.isNotEmpty) {
        double limit = piecesInCols.map((e) => e.y).toList().reduce(min) - sideLength;
        return limit;
      } else {
        return sideLength * (sideCount - 1);
      }
    }
  }

  void setDragUpdate(String val) {
    dragUpdate = val;
    notifyListeners();
  }

  Future<void> selectImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);

    //debugPrint('Bytes: '+ (result?.files.single.bytes).toString());
    if (result != null && result.files.single.bytes != null) {
      puzzleService.setImageBytes(result.files.single.bytes);
    } else if (result != null && result.files.single.path != null) {
      puzzleService.setImageBytes(File(result.files.single.path!).readAsBytesSync());
    } else {
      // User canceled the picker
    }
  }

  void resize(BuildContext context) {
    setBusy(true);
    double oldSideLength = sideLength;
    double newSideLength = puzzleService.getSideLength(context);
    double scale = newSideLength / oldSideLength;

    puzzleService.setSideLength(newSideLength);
    puzzleService.setStartingPositions(puzzleService.getOffsetList());

    for (PuzzlePiece piece in pieces) {
      piece.pos = piece.pos.scale(scale, scale);
      piece.pos = Offset(puzzleService.roundToVal(piece.x, sideLength), puzzleService.roundToVal(piece.y, sideLength));
      piece.target = piece.target.scale(scale, scale);
      piece.target = Offset(puzzleService.roundToVal(piece.target.dx, sideLength), puzzleService.roundToVal(piece.target.dy, sideLength));
    }

    setBusy(false);
  }

  void shuffle() {
    startingPositions.shuffle();
    spinRight?.fire();
    jump?.fire();

    for (int x = 0; x < (sideCount * sideCount) - 1; x++) {
      pieces[x].pos = startingPositions[x];
    }

    notifyListeners();
  }

  void reset() {
    puzzleService.puzzleStarted = false;
    puzzleService.imageBytes = null;
    puzzleService.pieces = [];
    puzzleService.restart();
    swapMode = false;
    notifyListeners();
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices => [puzzleService];
}

enum MoveDirection {
  left,
  right,
  up,
  down,
}

extension MoveDirectionExtension on MoveDirection {
  bool get positive {
    switch (this) {
      case MoveDirection.left:
        return false;
      case MoveDirection.right:
        return true;
      case MoveDirection.up:
        return false;
      case MoveDirection.down:
        return true;
    }
  }
}
