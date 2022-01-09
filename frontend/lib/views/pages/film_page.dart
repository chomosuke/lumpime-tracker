import 'package:flutter/material.dart';
import '../index.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FilmPage extends HookConsumerWidget {
  final String id;
  const FilmPage(this.id, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Layout(
      topBar: TopBar(),
      navBar: NavBar(),
      page: Text('placeholder'),
    );
  }
}
