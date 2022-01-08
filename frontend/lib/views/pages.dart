import 'package:flutter/material.dart';
import 'index.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Page extends StatelessWidget {
  final Widget page;
  const Page({required this.page, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const TopBar(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const NavBar(),
            page,
          ],
        )
      ],
    );
  }
}

class QueryPage extends HookConsumerWidget {
  const QueryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    throw UnimplementedError();
  }
}

class FilmListPage extends HookConsumerWidget {
  final String listName;
  const FilmListPage(this.listName, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    throw UnimplementedError();
  }
}

class FilmPage extends HookConsumerWidget {
  final String id;
  const FilmPage(this.id, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    throw UnimplementedError();
  }
}
