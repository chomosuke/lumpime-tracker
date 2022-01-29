import 'dart:math';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'card.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SearchGrid extends HookConsumerWidget {
  final List<String> filmIds;
  final EdgeInsetsGeometry? padding;
  const SearchGrid(
    this.filmIds, {
    this.padding,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useScrollController();

    if (filmIds.isEmpty) {
      return const Center(
        child: Text('No anime found'),
      );
    }
    return LayoutBuilder(builder: (context, constraints) {
      const maxCrossAxisExtent = 200.0;

      final SliverGridDelegate delegate;
      if (constraints.maxWidth < 525) {
        delegate = const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2 / 3,
          crossAxisSpacing: 30,
          mainAxisSpacing: 30,
        );
      } else if (constraints.maxWidth < 600) {
        delegate = const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2 / 3,
          crossAxisSpacing: 30,
          mainAxisSpacing: 30,
        );
      } else {
        delegate = const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: maxCrossAxisExtent,
          childAspectRatio: 2 / 3,
          crossAxisSpacing: 30,
          mainAxisSpacing: 30,
        );
      }

      return Scrollbar(
        controller: controller,
        isAlwaysShown: true,
        child: GridView.builder(
          controller: controller,
          itemCount: filmIds.length,
          padding: const EdgeInsets.all(30)
              .add(padding ?? const EdgeInsets.all(0))
              .add(EdgeInsets.symmetric(
                horizontal: max((constraints.maxWidth - 1600) / 2, 0),
              )),
          gridDelegate: delegate,
          itemBuilder: (context, index) => Card(
            filmId: filmIds[index],
          ),
        ),
      );
    });
  }
}
