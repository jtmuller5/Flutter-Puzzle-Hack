import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'get_it.config.dart';

final getIt = GetIt.instance;

// flutter packages pub run build_runner watch
// flutter packages pub run build_runner build --delete-conflicting-outputs

@InjectableInit(
  initializerName: r'$initGetIt', // default
  preferRelativeImports: true, // default
  asExtension: false, // default

)

void configureDependencies({String? env}) {
  // Configure app-specific dependencies
  $initGetIt(getIt, environment: env);

}