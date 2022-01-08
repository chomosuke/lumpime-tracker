import 'package:flutter/material.dart';
import 'index.dart';

const appName = 'Lumpime Tracker';

const filmRoutePrefix = 'anime';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      onGenerateRoute: (settings) {
        if (settings.name == '/' || settings.name == null) {
          return MaterialPageRoute(builder: (context) => const QueryPage());
        }

        final uri = Uri.parse(settings.name!);

        if (uri.pathSegments.length == 1) {
          return MaterialPageRoute(
            builder: (context) => FilmListPage(uri.pathSegments[0]),
          );
        }

        if (uri.pathSegments.length == 2 &&
            uri.pathSegments[0] == filmRoutePrefix) {
          return MaterialPageRoute(
            builder: (context) => FilmPage(uri.pathSegments[1]),
          );
        }
      },
    );
  }
}
