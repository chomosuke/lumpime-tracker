import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:frontend/states/index.dart';
import 'package:frontend/views/app.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:styled_widget/styled_widget.dart';

const listNameToIcon = <String, Icon>{
  toWatch: Icon(Icons.watch_later),
  watching: Icon(Icons.remove_red_eye),
  watched: Icon(Icons.done),
  favorite: Icon(Icons.favorite),
};

const listNameToToolTip = <String, String>{
  toWatch: 'Watchlist',
  watching: 'Watching',
  watched: 'Completed',
  favorite: 'Favorite',
};

final routeNameProvider = StateProvider((ref) => '/');

class NavBar extends HookConsumerWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(routeNameProvider.state);
    final width = MediaQuery.of(context).size.width;
    final iconSize = width < 450 ? 40 / 450 * width : 40.0;
    return Column(
      children: [
        IconButton(
          iconSize: iconSize,
          onPressed: () {
            Navigator.of(navigatorKey.currentContext!).pushNamed('/');
            selected.state = '/';
            ref.read(queryRangeProvider.state).state = initQueryRange;
          },
          icon: const Icon(Icons.search),
          color: selected.state == '/' ? null : Colors.black54,
          tooltip: 'Search',
        ),
        ...listNames
            .map<Widget>(
              (listName) => IconButton(
                iconSize: iconSize,
                onPressed: () {
                  Navigator.of(navigatorKey.currentContext!)
                      .pushNamed('/$listName');
                  selected.state = listName;
                },
                icon: listNameToIcon[listName]!,
                color: selected.state == listName ? null : Colors.black54,
                tooltip: listNameToToolTip[listName],
              ),
            )
            .toList(),
      ],
    ).border(color: Colors.grey, right: 1);
  }
}
