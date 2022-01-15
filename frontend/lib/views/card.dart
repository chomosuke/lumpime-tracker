import 'package:flutter/material.dart' hide Card;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:frontend/http/index.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'card/index.dart';
import 'package:styled_widget/styled_widget.dart';

class Card extends HookConsumerWidget {
  final String filmId;
  final bool showEpisodeTracker;
  const Card({required this.showEpisodeTracker, required this.filmId, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filmFuture = useMemoized(() => filmGet(filmId), [filmId]);

    final film = useFuture(filmFuture);

    if (film.hasError) {
      return Text('Error: ${film.stackTrace}');
    }
    if (film.hasData) {
      final filmData = film.data!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          FilmDetails(filmData),
          FilmImage(imgUrl: filmData.imgUrl),
          FilmActions(filmId: filmId).center().expanded(),
        ],
      )
          .padding(all: 10)
          .constrained(
            width: 400,
            height: 600,
          )
          .fittedBox()
          .card(
            clipBehavior: Clip.antiAlias,
            elevation: 32,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
          );
    }
    return const Center(child: CircularProgressIndicator());
  }
}
