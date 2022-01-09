import 'package:flutter/material.dart' hide Card;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'index.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Grid extends HookConsumerWidget {
  final List<String> filmIds;
  final bool showEpisodeTracker;
  final String emptyMessage;
  final EdgeInsetsGeometry? padding;
  const Grid(
    this.filmIds, {
    this.showEpisodeTracker = false,
    this.emptyMessage = '',
    this.padding,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (filmIds.isEmpty) {
      return Center(
        child: Text(emptyMessage),
      );
    }

    const maxCrossAxisExtent = 182 * 2.0;
    return Scrollbar(
      isAlwaysShown: true,
      child: Center(
        child: SizedBox(
            width: 1600,
            child: GridView.builder(
              itemCount: filmIds.length,
              padding: const EdgeInsets.all(30)
                  .add(padding ?? const EdgeInsets.all(0)),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: maxCrossAxisExtent,
                childAspectRatio: 400 / 600,
                crossAxisSpacing: 30,
                mainAxisSpacing: 30,
              ),
              shrinkWrap: true,
              itemBuilder: (context, index) => Card(
                filmId: filmIds[index],
                showEpisodeTracker: showEpisodeTracker,
              ),
            )),
      ),
    );
  }
}
