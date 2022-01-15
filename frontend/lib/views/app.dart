import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'index.dart';

const appName = 'Lumpime Tracker';

const filmRoutePrefix = 'anime';

final navigatorKey = GlobalKey<NavigatorState>();

class App extends HookConsumerWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searching = useState(true);
    return MaterialApp(
      title: appName,
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      home: Layout(
        topBar: TopBar(search: searching.value),
        navBar: const NavBar(),
        page: Navigator(
          key: navigatorKey,
          initialRoute: '/',
          onGenerateRoute: (settings) {
            if (settings.name == '/' || settings.name == null) {
              searching.value = true;
              return MyPageRoute(
                builder: (context) => const QueryPage(),
              );
            } else {
              searching.value = false;
            }

            final uri = Uri.parse(settings.name!);

            if (uri.pathSegments.length == 1) {
              return MyPageRoute(
                builder: (context) => FilmListPage(uri.pathSegments[0]),
              );
            }
          },
        ),
      ),
    );
  }
}
