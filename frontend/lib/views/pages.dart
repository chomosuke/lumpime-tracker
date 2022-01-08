import 'package:flutter/material.dart';
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
      child: SizedBox(
        child: Column(
          children: [
            topBar,
            Row(
              children: [
                navBar,
                page,
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class QueryPage extends HookConsumerWidget {
  const QueryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Page(
      topBar: const TopBar(search: true),
      navBar: const NavBar(),
      page: Text('placeholder'),
    );
  }
}

class FilmListPage extends HookConsumerWidget {
  final String listName;
  const FilmListPage(this.listName, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Page(
      topBar: const TopBar(),
      navBar: const NavBar(),
      page: Text('placeholder'),
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
