import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:puzzle/app/resources/reusables.dart';
import 'package:puzzle/services/services.dart';
import 'package:puzzle/ui/components/loading_overlay.dart';
import 'package:puzzle/ui/home/widgets/puzzle.dart';
import 'package:puzzle/ui/home/widgets/setup.dart';
import 'package:rive/rive.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:stacked/stacked.dart';
import 'package:universal_html/html.dart' hide Text;
import 'package:image/image.dart' as image;
import 'dart:math' as math;

import 'home_view_model.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      viewModelBuilder: () => HomeViewModel(context),
      builder: (context, model, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Scaffold(
              backgroundColor: Colors.grey.shade800,
              body: NotificationListener<SizeChangedLayoutNotification>(
                onNotification: (SizeChangedLayoutNotification notification) {
                  WidgetsBinding.instance?.addPostFrameCallback(
                    (_) {
                      model.resize(context);
                    },
                  );

                  return true;
                },
                child: Stack(
                  children: [
                    const RiveAnimation.asset(
                      'assets/animations/night.riv',
                      fit: BoxFit.cover,
                      animations: ['Moon', 'Twinkle'],
                    ),
                    LoopAnimation<double>(
                      duration: const Duration(seconds: 10),
                      tween: Tween<double>(begin: 0, end: MediaQuery.of(context).size.width + 200),
                      builder: (context, child, value) {
                        return Positioned(
                          bottom: -100,
                          right: -200 + value,
                          child: child!,
                        );
                      },
                      child: SizedBox(
                        height: puzzleService.sideLength * 2,
                        width: puzzleService.sideLength * 2,
                        child: RiveAnimation.asset(
                          'assets/animations/cow.riv',
                          fit: BoxFit.cover,
                          stateMachines: const ['Cow'],
                          onInit: (artboard) {
                            model.setCowMachine(artboard);
                          },
                        ),
                      ),
                    ),
                    SizeChangedLayoutNotifier(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 800),
                        child: Center(
                          child: ListView(
                            shrinkWrap: true,
                            // mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 60),
                              puzzleService.puzzleStarted ? Puzzle() : const Setup(),
                              gap24,
                              if (model.swapMode && puzzleService.puzzleStarted)
                                Center(
                                  child: Padding(
                                    padding: padding8,
                                    child: Text(
                                      'Tap 2 pieces to swap them',
                                      style: Theme.of(context).textTheme.caption!.copyWith(color: Colors.white),
                                    ),
                                  ),
                                ),
                              (puzzleService.imageBytes == null)
                                  ? Center(
                                      child: SizedBox(
                                        width: 300,
                                        child: FloatingActionButton.extended(
                                          onPressed: () async {
                                            await model.selectImage();
                                          },
                                          heroTag: 'control',
                                          label: Text(
                                            'Choose Image',
                                            style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    )
                                  : puzzleService.puzzleStarted
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                          child: SizedBox(
                                            height: 200,
                                            child: Column(
                                              children: [
                                                Flexible(
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Flexible(
                                                        child: SizedBox(
                                                          width: 300,
                                                          child: FloatingActionButton.extended(
                                                              heroTag: 'restart',
                                                              onPressed: () {
                                                                model.shuffle();
                                                                puzzleService.restart();
                                                              },
                                                              label: Text(
                                                                'Restart',
                                                                style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white),
                                                              )),
                                                        ),
                                                      ),
                                                      gap8,
                                                      Flexible(
                                                        child: SizedBox(
                                                          width: 300,
                                                          child: FloatingActionButton.extended(
                                                              heroTag: 'swap',
                                                              backgroundColor:
                                                                  model.swapMode ? Colors.deepPurpleAccent : Colors.grey.shade200.withOpacity(.5),
                                                              onPressed: () {
                                                                model.toggleSwapMode();
                                                              },
                                                              label: Text(
                                                                'Swap',
                                                                style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white),
                                                              )),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                gap8,
                                                Flexible(
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Flexible(
                                                        child: SizedBox(
                                                          width: 300,
                                                          child: FloatingActionButton.extended(
                                                              heroTag: 'shuffle',
                                                              onPressed: () {
                                                                model.shuffle();
                                                              },
                                                              label: Text(
                                                                'Shuffle',
                                                                style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white),
                                                              )),
                                                        ),
                                                      ),
                                                      gap8,
                                                      Flexible(
                                                        child: SizedBox(
                                                          width: 300,
                                                          child: FloatingActionButton.extended(
                                                              heroTag: 'new image',
                                                              onPressed: () {
                                                                model.reset();
                                                              },
                                                              label: Text(
                                                                'New Image',
                                                                style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white),
                                                              )),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Center(
                                          child: SizedBox(
                                            width: 300,
                                            child: FloatingActionButton.extended(
                                              heroTag: 'start',
                                              onPressed: () async {
                                                model.setBusy(true);

                                                if (kIsWeb) {

                                                  /// DOES NOT WORK IN RELEASE MODE
                                                  /*var myWorker = Worker('worker.js');

                                                  myWorker.onMessage.listen((e) {
                                                    //List<Uint8List>
                                                    List<dynamic> computedPieces = e.data;

                                                    debugPrint('type : ' + computedPieces.runtimeType.toString());

                                                    List<Uint8List> pieces = computedPieces.map((e) => Uint8List.fromList(List<int>.from(e))).toList();
                                                    puzzleService.images = pieces;
                                                    model.startPuzzle();
                                                    model.setBusy(false);
                                                  });

                                                  myWorker.postMessage([
                                                    puzzleService.imageBytes,
                                                    puzzleService.sideCount,
                                                    puzzleService.sideLength,
                                                  ]);*/

                                                  List<Uint8List> pieces = getPieces([
                                                    puzzleService.imageBytes,
                                                    puzzleService.sideCount,
                                                    puzzleService.sideLength,
                                                  ]);
                                                  debugPrint('Done');

                                                  puzzleService.images = pieces;
                                                  model.startPuzzle();
                                                  model.setBusy(false);
                                                } else {
                                                  List<Uint8List>? pieces = await compute(getPieces, {
                                                    'imageData': puzzleService.imageBytes,
                                                    'sideCount': puzzleService.sideCount,
                                                    'sideLength': puzzleService.sideLength,
                                                  });

                                                  puzzleService.images = pieces ?? [];
                                                  model.startPuzzle();
                                                  model.setBusy(false);
                                                }
                                              },
                                              label: Text(
                                                'Start',
                                                style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white),
                                              ),
                                              icon: const Icon(
                                                Icons.cut,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                              const SizedBox(height: 60)
                            ],
                          ),
                        ),
                      ),
                    ),
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      top: MediaQuery.of(context).size.height / 2 - (((puzzleService.sideCount / 2) + 1) * puzzleService.sideLength), // +
                      //(model.activePiece?.y ?? 0),
                      left: MediaQuery.of(context).size.width / 2 -
                          ((puzzleService.sideCount / 2) * puzzleService.sideLength) +
                          (model.activePiece?.x ?? 0),
                      child: SizedBox(
                        width: model.sideLength * 1.5,
                        height: model.sideLength * 1.5,
                        child: IgnorePointer(
                          ignoring: true,
                          child: RiveAnimation.asset(
                            'assets/animations/ufo.riv',
                            fit: BoxFit.cover,
                            stateMachines: const ['optimized'],
                            onInit: (artboard) {
                              model.setStateMachine(artboard);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (model.isBusy) const LoadingOverlay()
          ],
        );
      },
    );
  }
}

double roundToVal(double input, double rounder) {
  return (input / rounder).round() * rounder;
}

List<Uint8List> getPieces(dynamic dataMap) {
  dynamic imageData = dataMap[0];
  int sideCount = puzzleService.sideCount;
  double sideLength = puzzleService.sideLength;

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

    image.Image? fittedImage = image.copyCrop(resizedImage, roundToVal(midX - fitSide, 2).toInt(), roundToVal(midY - fitSide, 2).toInt(),
        roundToVal(midX + fitSide, 2).toInt(), roundToVal(midY + fitSide, 2).toInt());

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

      computedPieces.add(Uint8List.fromList(image.encodeJpg(cropped)));

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

  return [];
}
