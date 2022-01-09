import 'package:flutter/material.dart' hide Card;
import 'package:flutter/material.dart' as material show Card;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:frontend/http/index.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'card/index.dart';

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
      return Text('Error ${film.error}');
    }
    if (film.hasData) {
      final filmData = film.data!;
      return FittedBox(
        child: material.Card(
          clipBehavior: Clip.antiAlias,
          elevation: 32,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Container(
            width: 400,
            height: 600,
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                FilmDetails(filmData),
                FilmImage(imgUrl: filmData.imgUrl),
                FilmActions(filmId: filmId),
              ],
            ),
          ),
        ),
      );
    }
    return const Center(child: CircularProgressIndicator());
  }
}
