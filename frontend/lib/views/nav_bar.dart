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
  liked: Icon(Icons.thumb_up_alt),
  saved: Icon(Icons.bookmark),
};

const listNameToToolTip = <String, String>{
  toWatch: 'Watchlist',
  watching: 'Watching',
  watched: 'Completed',
  liked: 'Liked',
  saved: 'Bookmarked',
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
    ).decorated(
      border: const Border(right: BorderSide(color: Colors.grey, width: 1)),
    );
  }
}
