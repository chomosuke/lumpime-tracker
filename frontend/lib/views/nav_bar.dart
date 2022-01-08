import 'package:flutter/material.dart';
import 'package:frontend/states/index.dart';
import 'package:frontend/views/app.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const listNameToIcon = <String, Icon>{
  toWatch: Icon(Icons.watch_later),
  watching: Icon(Icons.remove_red_eye),
  watched: Icon(Icons.done),
  liked: Icon(Icons.thumb_up_alt),
  saved: Icon(Icons.bookmark),
};

class NavBar extends HookConsumerWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.grey, width: 1),
        ),
      ),
      child: Column(
        children: [
          IconButton(
            iconSize: 40,
            onPressed: () {
              Navigator.of(navigatorKey.currentContext!).pushNamed('/');
            },
            icon: const Icon(Icons.search),
          ),
          ...listNames
              .map<Widget>(
                (listName) => IconButton(
                  iconSize: 40,
                  onPressed: () {
                    Navigator.of(navigatorKey.currentContext!)
                        .pushNamed('/$listName');
                  },
                  icon: listNameToIcon[listName]!,
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}
