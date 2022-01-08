import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Grid extends HookConsumerWidget {
  final List<String> filmIds;
  final bool showEpisodeTracker;
  final String emptyMessage;
  const Grid(
    this.filmIds, {
    this.showEpisodeTracker = false,
    this.emptyMessage = '',
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (filmIds.isEmpty) {
      return Center(
        child: Text(emptyMessage),
      );
    }

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
