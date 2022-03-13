import 'package:get_it/get_it.dart';
import 'package:puzzle/services/puzzle_service.dart';
import 'package:puzzle/services/utilities/time_service.dart';
import 'package:puzzle/services/utilities/timer_service.dart';
import 'utilities/app_service.dart';

AppService get appService {
  return GetIt.instance.get<AppService>();
}

PuzzleService get puzzleService {
  return GetIt.instance.get<PuzzleService>();
}

TimeService get timeService {
  return GetIt.instance.get<TimeService>();
}

TimerService get timerService {
  return GetIt.instance.get<TimerService>();
}
