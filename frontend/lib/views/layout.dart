import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Layout extends HookConsumerWidget {
  final Widget topBar;
  final Widget navBar;
  final Widget page;
  const Layout({
    required this.topBar,
    required this.navBar,
    required this.page,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
