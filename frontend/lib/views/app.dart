import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:frontend/states/index.dart';
import 'package:frontend/views/filters.dart';

import 'nav_bar.dart';
import 'page_route.dart';
import 'query/index.dart';
import 'list/index.dart';
import 'top_bar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:styled_widget/styled_widget.dart';

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
        if (settings.name == '/' || settings.name == null) {
          return MyPageRoute(
            builder: (context) => const SearchPage(
              topPadding: 72,
            ),
          );
        }

        final uri = Uri.parse(settings.name!);

        if (uri.pathSegments.length == 1) {
          return MyPageRoute(
            builder: (context) => FilmListPage(
              listName: uri.pathSegments[0],
              topPadding: 72,
            ),
          );
        }
      },
    );

    return MaterialApp(
      title: appName,
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      home: Material(
        child: Column(
          children: [
            const TopBar(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const NavBar(),
                Stack(
                  children: [
                    navigator,
                    const Filters(),
                  ],
                ).expanded(),
              ],
            ).expanded(),
          ],
        ),
      ),
    );
  }
}
