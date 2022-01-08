import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyPageRoute extends PageRouteBuilder {
  final Widget Function(BuildContext) builder;
  MyPageRoute({required this.builder})
      : super(
          pageBuilder: (
            context,
            animation,
            secondaryAnimation,
          ) =>
              builder(context),
          transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
          ) {
            final tween = Tween(begin: 0.0, end: 1.0);
            return FadeTransition(
              opacity: animation.drive(tween),
              child: Material(child: child),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}
