import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:styled_widget/styled_widget.dart';

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              navBar,
              page.expanded(),
            ],
          ).expanded(),
        ],
      ),
    );
  }
}
