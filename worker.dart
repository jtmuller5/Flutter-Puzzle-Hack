@JS()
library sample;

import 'dart:typed_data';
import 'package:js/js.dart';
import 'package:universal_html/html.dart';
import 'package:image/image.dart' as image;


@JS('self')
external DedicatedWorkerGlobalScope get self;

/// => /Mullr/flutter/bin/cache/dart-sdk/bin/dart2js -o worker.js worker.dart
void main() {
  self.onMessage.listen((MessageEvent e) {

    dynamic imageData = e.data[0];
    int sideCount = e.data[1];
    double sideLength = e.data[2];

    List<Uint8List>? pieces = getPieces(imageData, sideCount, sideLength);
    self.postMessage(pieces, null);
  });
}

double roundToVal(double input, double rounder) {
  return (input / rounder).round() * rounder;
}

List<Uint8List>? getPieces(dynamic imageData, int sideCount, double sideLength) {
  image.Image? fullImage = image.decodeImage(imageData);

  List<Uint8List> computedPieces = [];

  if (fullImage != null) {
    double puzzleSide = sideLength * sideLength;

    image.Image? resizedImage;
    if (fullImage.width < puzzleSide || fullImage.height < puzzleSide) {
      resizedImage = image.copyResizeCropSquare(fullImage, (sideLength * sideCount).toInt());
    }

    resizedImage ??= fullImage;
    double midX = resizedImage.width / 2;
    double midY = resizedImage.height / 2;
    double fitSide = (sideCount / 2) * sideLength;

    image.Image? fittedImage =  image.copyCrop(
        resizedImage,
        roundToVal(midX - fitSide, 2).toInt(),
        roundToVal(midY - fitSide, 2).toInt(),
        roundToVal(midX + fitSide, 2).toInt(),
        roundToVal(midY + fitSide, 2).toInt());

    int row = 0;
    int col = 0;

    for (int x = 0; x < (sideCount * sideCount) - 1; x++) {
      image.Image cropped = image.copyCrop(
        fittedImage,
        (col * sideLength).toInt(),
        (row * sideLength).toInt(),
        sideLength.toInt(),
        sideLength.toInt(),
      );

      computedPieces.add(Uint8List.fromList(image.encodeJpg(cropped, quality: 50)));
      // model.setPieceImage(model.pieces[x],  Uint8List.fromList(image.encodeJpg(cropped,quality: 50)));

      if ((x + 1) % sideCount == 0) {
        row++;
      }

      if (col == sideCount - 1) {
        col = 0;
      } else {
        col++;
      }
    }

    return computedPieces;

  }
}
