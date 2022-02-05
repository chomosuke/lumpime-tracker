import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:frontend/helpers/measure_size.dart';
import 'package:frontend/states/index.dart';
import 'package:frontend/views/filters.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:styled_widget/styled_widget.dart';

import 'nav_bar.dart';
import 'page_route.dart';
import 'query/index.dart';
import 'list/index.dart';
import 'top_bar.dart';

const appName = 'Lumpime Tracker';

const filmRoutePrefix = 'anime';

final navigatorKey = GlobalKey<NavigatorState>();

class App extends HookConsumerWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigator = Navigator(
      key: navigatorKey,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name != ref.read(routeNameProvider)) {
          ref.read(queryProvider.state).state = initQuery;
        }
        if (settings.name == '/' || settings.name == null) {
          return MyPageRoute(
            builder: (context) => const SearchPage(
              header: Filters(),
            ),
          );
        }

        final uri = Uri.parse(settings.name!);

        if (uri.pathSegments.length == 1) {
          return MyPageRoute(
            builder: (context) => FilmListPage(
              header: const Filters(),
              listName: uri.pathSegments[0],
            ),
          );
        }
      },
    );

    final home = Column(
      children: [
        const TopBar(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const NavBar(),
            navigator.expanded(),
          ],
        ).expanded(),
      ],
    ).material();

    return LayoutBuilder(
      builder: (context, constraints) => MaterialApp(
        title: appName,
        theme: ThemeData(
          primarySwatch: Colors.lightBlue,
        ),
        home: home,
      ),
    );
  }
}
