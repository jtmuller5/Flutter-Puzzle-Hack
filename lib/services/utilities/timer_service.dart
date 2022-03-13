import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';

@lazySingleton
class TimerService with ReactiveServiceMixin {

  Stopwatch stopwatch =Stopwatch();
  ValueNotifier<Duration> elapsed = ValueNotifier(Duration.zero);

  /// Each instance of the timerService should manage just a single timer
  /// A one-time countdown timer
  Timer? timer;

  /// A repeating timer
  Timer? periodicTimer;


  /// The amount of time remaining in the timer, once the elapsed duration == rest duration, sound the alarm
  Duration elapsedDuration = Duration.zero;

  void startStopwatch(){
    stopwatch.start();
    debugPrint('Timer started');

    startPeriodicTimer(interval: const Duration(seconds: 1), callback: (timer){
      elapsed.value = stopwatch.elapsed;
      notifyListeners();
    });
  }

  Duration? get getElapsedTime {
    return stopwatch.elapsed;
  }

  void startTimer({
    required Duration interval,
    required Function() callback,
  }) {
    timer = Timer(interval, callback);
  }

  void startPeriodicTimer({
    required Duration interval,
    required Function(Timer) callback,
  }) {
    periodicTimer = Timer.periodic(interval, callback);
  }

  void cancelTimer() {
    if (timer != null) {
      timer!.cancel();
    }
  }

  void cancelPeriodicTimer() {
    if (periodicTimer != null) {
      periodicTimer!.cancel();
    }
  }


  void resetTimer() {
    elapsedDuration = Duration.zero;
    if (periodicTimer != null) {
      periodicTimer!.cancel();
    }
    notifyListeners();
  }
}
