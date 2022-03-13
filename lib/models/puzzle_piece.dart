import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class PuzzlePiece {
  /// Coordinate of top left
  int id;
  Offset pos;
  Offset target;
  bool empty;
  Color color;
  bool active;
  Uint8List? image;

  double get x {
    return pos.dx;
  }

  double get y {
    return pos.dy;
  }

  bool get onTarget {
    return pos == target;
  }

  PuzzlePiece({
    required this.id,
    required this.pos,
    required this.target,
    required this.empty,
    required this.color,
    required this.active,
    this.image,
  });
}
