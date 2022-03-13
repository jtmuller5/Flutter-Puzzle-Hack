import 'package:rive/rive.dart';
import 'package:stacked/stacked.dart';

class SolvedViewModel extends BaseViewModel {
  StateMachineController? ufoController;

  SMITrigger? spinRight;
  SMITrigger? spinLeft;
  SMITrigger? pulse;
  SMITrigger? attract;

  void initialize() {}

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
}
