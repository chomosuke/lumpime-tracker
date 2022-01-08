import 'package:flutter/material.dart';
import 'package:frontend/states/index.dart';
import '../index.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FilmListPage extends HookConsumerWidget {
  final String listName;
  const FilmListPage(this.listName, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountData = ref.watch(accountDataProvider);

    return accountData.when(
      loading: () => const Center(
        child: SizedBox(
          width: 500,
          child: LinearProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => Text('Error: $error'),
      data: (accountData) => accountData == null
          ? const Center(
              child: Text('Log In to save anime to a list'),
            )
          : Grid(
              accountData.filmIdLists[listName]!.list,
              showEpisodeTracker: listName == watching,
              emptyMessage: 'You don\'t have any anime in this list',
            ),
    );
  }
}
