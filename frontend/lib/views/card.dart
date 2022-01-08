import 'package:flutter/material.dart' as material show Card;
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Card extends HookConsumerWidget {
  final String filmId;
  final bool showEpisodeTracker;
  const Card({required this.showEpisodeTracker, required this.filmId, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return material.Card(
      clipBehavior: Clip.antiAlias,
      elevation: 32,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Text(filmId),
    );
  }
}
