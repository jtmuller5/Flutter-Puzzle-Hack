import 'package:rive/rive.dart';
import 'package:stacked/stacked.dart';

class SolvedViewModel extends BaseViewModel {
  StateMachineController? ufoController;
  StateMachineController? cowController;

  SMITrigger? spinRight;
  SMITrigger? spinLeft;
  SMITrigger? pulse;
  SMITrigger? attract;
  SMITrigger? jump;


  void setCowMachine(Artboard artboard) {
    if (cowController == null) {
      cowController = StateMachineController.fromArtboard(artboard, 'cow');
      artboard.addController(cowController!);
      jump = cowController!.findInput<bool>('Jump') as SMITrigger;
      notifyListeners();
    }
  }

  void setStateMachine(Artboard artboard) {
    if (ufoController == null) {
      ufoController = StateMachineController.fromArtboard(artboard, 'abduct');
      artboard.addController(ufoController!);
      notifyListeners();
    }
  }
}
