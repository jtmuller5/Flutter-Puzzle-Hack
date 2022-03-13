import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:puzzle/app/resources/reusables.dart';
import 'package:puzzle/models/puzzle_piece.dart';
import 'package:puzzle/services/services.dart';
import 'package:puzzle/ui/home/home_view_model.dart';
import 'package:puzzle/ui/home/widgets/elapsed_time.dart';
import 'package:stacked/stacked.dart';

class Puzzle extends ViewModelWidget<HomeViewModel> {
  @override
  Widget build(BuildContext context, HomeViewModel model) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (event) {
        if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
          model.keyMovement(MoveDirection.up);
        } else if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
          model.keyMovement(MoveDirection.down);
        } else if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
          model.keyMovement(MoveDirection.left);
        } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
          model.keyMovement(MoveDirection.right);
        }

        checkForSolve(context);
      },
      child: Center(
        child: ListView(
          shrinkWrap: true,
         // mainAxisSize: MainAxisSize.min,
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IgnorePointer(
                  ignoring: model.isBusy,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: model.swapMode ? Colors.deepPurpleAccent.withOpacity(.3) : Colors.black26,
                      borderRadius: circular8,
                    ),
                    child: SizedBox(
                      height: model.sideLength * model.sideCount,
                      width: model.sideLength * model.sideCount,
                      child: Stack(
                        children: [
                          for (PuzzlePiece piece in model.pieces)
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 100),
                              curve: Curves.decelerate,
                              top: piece.y,
                              left: piece.x,
                              child: Stack(
                                children: [
                                  SizedBox(
                                    width: model.sideLength,
                                    height: model.sideLength,
                                    child: AnimatedScale(
                                      duration: kThemeAnimationDuration,
                                      scale: model.activePiece?.id == piece.id ? 1.07 : 1,
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        margin: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          borderRadius: circular8,
                                          border: Border.all(
                                            color: (model.activePiece?.id == piece.id && !model.swapMode) ? Colors.deepPurple : Colors.transparent,
                                            width: 3,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: model.activePiece?.id == piece.id ? Colors.deepPurple : Colors.black26,
                                              blurRadius: 4,
                                              offset: const Offset(2, 2),
                                            ),
                                          ],
                                          image: DecorationImage(
                                            image: MemoryImage(piece.image!),
                                            fit: BoxFit.cover,
                                            colorFilter: piece.onTarget
                                                ? null
                                                : const ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                          ),
                                        ),
                                        child: Center(
                                          child: Builder(
                                            builder: (context) {
                                              if (model.swapMode && (model.swapPiece1?.id == piece.id)) {
                                                return Center(
                                                  child: Text(
                                                    'Swap',
                                                    style: Theme.of(context).textTheme.headline5!.copyWith(color: Colors.purpleAccent),
                                                  ),
                                                );
                                              } else {
                                                return Container();
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: model.sideLength,
                                    height: model.sideLength,
                                    child: Container(
                                      margin: const EdgeInsets.all(4),
                                      child: GestureDetector(
                                        onHorizontalDragUpdate: (details) async {
                                          model.setActivePiece(piece);
                                          model.moveHorizontally(piece, details.delta.dx);
                                        },
                                        onHorizontalDragEnd: (details) {
                                          Offset newOffset = Offset(model.getNearestSnap(piece.x), piece.y);

                                          if (piece.pos.dx != newOffset.dx) {
                                            puzzleService.incrementMoves();
                                          }

                                          piece.pos = newOffset;
                                          HapticFeedback.mediumImpact();
                                          model.notifyListeners();
                                          checkForSolve(context);
                                        },
                                        onVerticalDragEnd: (details) {
                                          Offset newOffset = Offset(piece.x, model.getNearestSnap(piece.y));

                                          if (piece.pos.dy != newOffset.dy) {
                                            puzzleService.incrementMoves();
                                          }
                                          piece.pos = newOffset;
                                          HapticFeedback.mediumImpact();
                                          model.notifyListeners();
                                          checkForSolve(context);
                                        },
                                        onVerticalDragUpdate: (details) async {
                                          model.setActivePiece(piece);
                                          model.moveVertically(piece, details.delta.dy);
                                        },
                                        child: Material(
                                          color: Colors.transparent,
                                          borderRadius: circular8,
                                          child: InkWell(
                                            borderRadius: circular8,
                                            splashColor: Colors.purple.withOpacity(.5),
                                            onTap: () {
                                              if (!model.swapMode) {
                                                bool moved = model.moveVertically(piece, puzzleService.sideLength, tapped: true);

                                                if (!moved) {
                                                  moved = model.moveVertically(piece, puzzleService.sideLength * -1, tapped: true);
                                                }

                                                if (!moved) {
                                                  moved = model.moveHorizontally(piece, puzzleService.sideLength, tapped: true);
                                                }

                                                if (!moved) {
                                                  moved = model.moveHorizontally(piece, puzzleService.sideLength * -1, tapped: true);
                                                }

                                                model.setActivePiece(piece);
                                                checkForSolve(context);
                                              } else {
                                                if(model.swapPiece1 == null) model.setActivePiece(piece);
                                                model.swapPiece(piece);
                                                checkForSolve(context);
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            gap16,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      'Moves',
                      style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white),
                    ),
                    Text('${puzzleService.totalMoves}',
                      style: Theme.of(context).textTheme.headline5!.copyWith(color: Colors.white),)
                  ],
                ),
                gap36,
                Column(
                  children: [
                    Text(
                      'Swaps',
                      style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white),
                    ),
                    Text('${puzzleService.totalSwaps}',
                    style: Theme.of(context).textTheme.headline5!.copyWith(color: Colors.white),)
                  ],
                ),
                gap36,
                ElapsedTime(),

              ],
            )
          ],
        ),
      ),
    );
  }

  void checkForSolve(BuildContext context){
    debugPrint('Checking for solve');
    if(puzzleService.puzzleSolved){
      timerService.stopwatch.stop();
      GoRouter.of(context).go('/solved');
    }
  }
}
