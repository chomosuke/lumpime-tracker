import 'package:flutter/material.dart';
import 'package:frontend/states/index.dart';
import 'film_list.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FilmListPage extends HookConsumerWidget {
  final String listName;
  final double topPadding;
  const FilmListPage({required this.listName, this.topPadding = 0, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final username = ref.watch(usernameProvider).value;

    if (username == null) {
      return const Center(
        child: Text('Log In to save anime to a list'),
      );
    }

    return FilmList(
      name: listName,
      showEpisodeTracker: listName == watching,
      padding: EdgeInsets.only(top: topPadding),
    );
  }
}
