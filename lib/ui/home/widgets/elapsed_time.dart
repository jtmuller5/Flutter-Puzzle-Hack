import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:puzzle/services/services.dart';
import 'package:puzzle/services/utilities/timer_service.dart';

class ElapsedTime extends StatelessWidget with GetItMixin{
  ElapsedTime({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Duration elapsed = watchX((TimerService x) => x.elapsed);


    return Column(
      children: [
        Text(
          'Elapsed',
          style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white),
        ),
        Text(timeService.getFormattedText(elapsed,includeHour: false),
          style: Theme.of(context).textTheme.headline5!.copyWith(color: Colors.white),)
      ],
    );
  }
}
