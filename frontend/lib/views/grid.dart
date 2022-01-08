import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Grid extends HookConsumerWidget {
  final List<String> filmIds;
  final bool showEpisodeTracker;
  const Grid(this.filmIds, {this.showEpisodeTracker = false, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.extent(
      padding: const EdgeInsets.all(30),
      maxCrossAxisExtent: 182 * 2,
      crossAxisSpacing: 30,
      mainAxisSpacing: 30,
      shrinkWrap: true,
      children: filmIds
          .map<Text>(
            (filmId) => Text(filmId),
          )
          .toList(),
    );
  }
}
