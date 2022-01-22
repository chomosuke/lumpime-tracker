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

class NavBar extends HookConsumerWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = useState('/');
    return Column(
      children: [
        IconButton(
          iconSize: 40,
          onPressed: () {
            Navigator.of(navigatorKey.currentContext!).pushNamed('/');
            selected.value = '/';
            ref.read(queryRangeProvider.state).state = initQueryRange;
          },
          icon: const Icon(Icons.search),
          color: selected.value == '/' ? null : Colors.black54,
          tooltip: 'Search',
        ),
        ...listNames
            .map<Widget>(
              (listName) => IconButton(
                iconSize: 40,
                onPressed: () {
                  Navigator.of(navigatorKey.currentContext!)
                      .pushNamed('/$listName');
                  selected.value = listName;
                },
                icon: listNameToIcon[listName]!,
                color: selected.value == listName ? null : Colors.black54,
                tooltip: listNameToToolTip[listName],
              ),
            )
            .toList(),
      ],
    ).border(color: Colors.grey, right: 1);
  }
}
