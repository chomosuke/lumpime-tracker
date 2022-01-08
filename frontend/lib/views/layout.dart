import 'package:flutter/material.dart';

class Layout extends StatelessWidget {
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
