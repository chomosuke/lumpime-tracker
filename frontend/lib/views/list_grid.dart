import 'dart:math';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:frontend/http/index.dart';
import 'package:frontend/states/index.dart';
import 'package:tuple/tuple.dart';
import 'index.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ListGrid extends HookConsumerWidget {
  final List<String> filmIds;
  final bool showEpisodeTracker;
  final String emptyMessage;
  final EdgeInsetsGeometry? padding;
  const ListGrid(
    this.filmIds, {
    this.showEpisodeTracker = false,
    this.emptyMessage = '',
    this.padding,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var filmIds = this.filmIds;
    final query = ref.watch(queryProvider);
    final filmIdsSnapshot = useFuture(filterViaQuery(filmIds, query));
    if (filmIdsSnapshot.hasData) {
      filmIds = filmIdsSnapshot.data!;
    }

    if (filmIds.isEmpty) {
      return Center(
        child: Text(emptyMessage),
      );
    }

    final controller = useScrollController();

    const maxCrossAxisExtent = 182 * 2.0;
    return LayoutBuilder(
      builder: (context, constrains) => Scrollbar(
        controller: controller,
        isAlwaysShown: true,
        child: GridView.builder(
          controller: controller,
          itemCount: filmIds.length,
          padding: const EdgeInsets.all(30)
              .add(padding ?? const EdgeInsets.all(0))
              .add(EdgeInsets.symmetric(
                horizontal: max((constrains.maxWidth - 1600) / 2, 0),
              )),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: maxCrossAxisExtent,
            childAspectRatio: 400 / 600,
            crossAxisSpacing: 30,
            mainAxisSpacing: 30,
          ),
          itemBuilder: (context, index) => ListCard(
            filmId: filmIds[index],
            showEpisodeTracker: showEpisodeTracker,
          ),
        ),
      ),
    );
  }

  Future<List<String>> filterViaQuery(List<String> filmIds, Query query) async {
    if (query.genres.isEmpty && query.seasons.isEmpty && query.text.isEmpty) {
      return filmIds;
    }

    final result = <String>[];
    final filmTuples = await Future.wait(
        filmIds.map((id) async => Tuple2<String, Film>(id, await filmGet(id))));
    for (final filmTuple in filmTuples) {
      final film = filmTuple.item2;
      if (query.genres.isNotEmpty &&
          query.genres.any((genre) => !film.genres.contains(genre))) {
        // if any query genres isn't contained by the film
        continue;
      }
      if (query.seasons.isNotEmpty &&
          !query.seasons.any((season) => film.seasons.contains(season))) {
        // if no query season is contained by the film
        continue;
      }
      if (query.text.isNotEmpty &&
          !query.text.split(' ').every((token) {
            String keyWords = film.altNames.join(' ') +
                ' ' +
                film.name +
                ' ' +
                film.englishName;
            return keyWords.toLowerCase().contains(token.toLowerCase());
          })) {
        // if film doesn't contain every token of query
        continue;
      }
      result.add(filmTuple.item1);
    }
    return result;
  }
}
