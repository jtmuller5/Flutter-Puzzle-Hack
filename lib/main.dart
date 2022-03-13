import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:go_router/go_router.dart';
import '../app/get_it.dart';
import '../app/themes/light_theme.dart';
import 'app/go_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  GoRouter.setUrlPathStrategy(UrlPathStrategy.path);
  runApp(
    MaterialApp(
      theme: lightTheme,
      home: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
          systemStatusBarContrastEnforced: false),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (context, nativeNavigator) {
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Portal(
              child: MaterialApp.router(
                theme: lightTheme,
                routeInformationParser: goRouter.routeInformationParser,
                routerDelegate: goRouter.routerDelegate,
                title: 'The Abduction',
              ),),
          );
        },
      )
    );
  }
}