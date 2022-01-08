import 'package:flutter/material.dart';
import 'package:frontend/states/index.dart';
import 'index.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Page extends StatelessWidget {
  final Widget topBar;
  final Widget navBar;
  final Widget page;
  const Page({
    required this.topBar,
    required this.navBar,
    required this.page,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          topBar,
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                navBar,
                Expanded(child: page),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class QueryPage extends HookConsumerWidget {
  const QueryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queryResult = ref.watch(queryResultProvider);

    return Page(
      topBar: const TopBar(search: true),
      navBar: const NavBar(),
      page: queryResult.when(
        loading: () => const Center(
          child: SizedBox(
            width: 500,
            child: LinearProgressIndicator(),
          ),
        ),
        error: (error, stackTrace) => Text('Error: $error'),
        data: (queryResult) => Grid(queryResult.filmIds),
      ),
    );
  }
}

class FilmListPage extends HookConsumerWidget {
  final String listName;
  const FilmListPage(this.listName, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountData = ref.watch(accountDataProvider);

    return Page(
      topBar: const TopBar(search: true),
      navBar: const NavBar(),
      page: accountData.when(
        loading: () => const Center(
          child: SizedBox(
            width: 500,
            child: LinearProgressIndicator(),
          ),
        ),
        error: (error, stackTrace) => Text('Error: $error'),
        data: (accountData) => accountData == null
            ? const Center(child: Text('Log In to save anime to a list'))
            : Grid(accountData.filmIdLists[listName]!.list),
      ),
    );
  }
}

class FilmPage extends HookConsumerWidget {
  final String id;
  const FilmPage(this.id, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Page(
      topBar: const TopBar(),
      navBar: const NavBar(),
      page: Text('placeholder'),
    );
  }
}
