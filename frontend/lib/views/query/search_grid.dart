import 'dart:math';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'card.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SearchGrid extends HookConsumerWidget {
  final List<String> filmIds;
  final EdgeInsetsGeometry? padding;
  final ScrollController controller;
  const SearchGrid(
    this.filmIds, {
    required this.controller,
    this.padding,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (filmIds.isEmpty) {
      return const Center(
        child: Text('No anime found'),
      );
    }
    return LayoutBuilder(builder: (context, constraints) {
      const maxCrossAxisExtent = 200.0;

      final spacing =
          constraints.maxWidth < 500 ? 30 / 525 * constraints.maxWidth : 30.0;

      final SliverGridDelegate delegate;
      if (constraints.maxWidth < 525) {
        delegate = SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: cardWidth / cardHeight,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
        );
      } else if (constraints.maxWidth < 600) {
        delegate = SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: cardWidth / cardHeight,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
        );
      } else {
        delegate = SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: maxCrossAxisExtent,
          childAspectRatio: cardWidth / cardHeight,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
        );
      }

      return Scrollbar(
        controller: controller,
        isAlwaysShown: true,
        child: GridView.builder(
          controller: controller,
          itemCount: filmIds.length,
          padding: EdgeInsets.all(spacing)
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
