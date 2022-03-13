import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:puzzle/services/services.dart';
import 'package:rive/rive.dart';
import 'package:stacked/stacked.dart';
import '../../app/resources/reusables.dart';
import './solved_view_model.dart';

class SolvedView extends StatelessWidget {
  const SolvedView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SolvedViewModel>.reactive(
      viewModelBuilder: () => SolvedViewModel(),
      builder: (context, model, child) {
        return Scaffold(
            body: Stack(
          children: [
            const RiveAnimation.asset(
              'assets/animations/night.riv',
              fit: BoxFit.cover,
              animations: ['Moon', 'Twinkle'],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Well Done!',
                        style: Theme.of(context).textTheme.headline3!.copyWith(color: Colors.white),
                      ),
                      gap16,
                      Text(
                        'Moves: ' + puzzleService.totalMoves.toString(),
                        style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white),
                      ),
                      Text(
                        'Swaps: ' + puzzleService.totalSwaps.toString(),
                        style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white),
                      ),
                      Text(
                        'Elapsed: ' + timeService.getFormattedText(timerService.stopwatch.elapsed, includeHour: false),
                        style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                gap24,
                FloatingActionButton.extended(
                  heroTag: 'again',
                  onPressed: () {
                    puzzleService.restart();
                    puzzleService.clearPuzzle();
                    context.go('/');
                  },
                  label: const Text('Go Again!'),
                ),
                SizedBox(
                  width: puzzleService.sideLength * 1.5,
                  height: puzzleService.sideLength * 1.5,
                  child: IgnorePointer(
                    ignoring: true,
                    child: RiveAnimation.asset(
                      'assets/animations/ufo.riv',
                      fit: BoxFit.cover,
                      stateMachines: const ['abduct'],
                      onInit: (artboard) {
                        model.setStateMachine(artboard);
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: puzzleService.sideLength * 2,
                  width: puzzleService.sideLength * 2,
                  child: RiveAnimation.asset(
                    'assets/animations/cow.riv',
                    fit: BoxFit.cover,
                    stateMachines: const ['Abducted'],
                    onInit: (artboard) {
                      model.setCowMachine(artboard);
                    },
                  ),
                ),
              ],
            )
          ],
        ));
      },
    );
  }
}
