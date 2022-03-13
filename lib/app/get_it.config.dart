// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../services/puzzle_service.dart' as _i4;
import '../services/utilities/app_service.dart' as _i3;
import '../services/utilities/time_service.dart' as _i5;
import '../services/utilities/timer_service.dart'
    as _i6; // ignore_for_file: unnecessary_lambdas

// ignore_for_file: lines_longer_than_80_chars
/// initializes the registration of provided dependencies inside of [GetIt]
_i1.GetIt $initGetIt(_i1.GetIt get,
    {String? environment, _i2.EnvironmentFilter? environmentFilter}) {
  final gh = _i2.GetItHelper(get, environment, environmentFilter);
  gh.singleton<_i3.AppService>(_i3.AppService());
  gh.lazySingleton<_i4.PuzzleService>(() => _i4.PuzzleService());
  gh.factory<_i5.TimeService>(() => _i5.TimeService());
  gh.lazySingleton<_i6.TimerService>(() => _i6.TimerService());
  return get;
}
