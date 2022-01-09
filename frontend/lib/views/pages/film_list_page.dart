import 'package:flutter/material.dart';
import 'package:frontend/states/index.dart';
import '../index.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FilmListPage extends HookConsumerWidget {
  final String listName;
  const FilmListPage(this.listName, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filmIdLists = ref.watch(filmIdListsProvider);
    final username = ref.watch(usernameProvider).value;

    if (username == null) {
      return const Center(
        child: Text('Log In to save anime to a list'),
      );
    }

    return filmIdLists == null
        ? const Center(
            child: SizedBox(
              width: 500,
              child: LinearProgressIndicator(),
            ),
          )
        : Grid(
            filmIdLists[listName]!.list,
            showEpisodeTracker: listName == watching,
            emptyMessage: 'You don\'t have any anime in this list',
          );
  }
}
