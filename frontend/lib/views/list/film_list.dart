import 'dart:math';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:frontend/http/index.dart';
import 'package:frontend/states/index.dart';
import 'list_item.dart';
import 'package:tuple/tuple.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:styled_widget/styled_widget.dart';

class FilmList extends HookConsumerWidget {
  final String name;
  final bool showEpisodeTracker;
  final EdgeInsets padding;
  final ScrollController controller;
  const FilmList({
    required this.name,
    required this.controller,
    this.showEpisodeTracker = false,
    this.padding = const EdgeInsets.only(),
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filmIds = ref.watch(filmIdListProvider(name))?.list;
    final query = ref.watch(queryProvider);

    final filmMap = useFuture(useMemoized<Future<Map<String, Film>>>(
      () async {
        final filmTuples = await Future.wait(
          (filmIds ?? []).map(
            (id) async => Tuple2<String, Film>(id, await filmGet(id)),
          ),
        );
        return {for (var e in filmTuples) e.item1: e.item2};
      },
      [filmIds],
    )).data;

    final nullFilmMap = filmIds == null ||
        filmMap == null ||
        filmIds.any((id) => filmMap[id] == null);

    if (filmIds == null || (nullFilmMap && !query.isEmpty)) {
      return const LinearProgressIndicator().width(500).center();
    }

    final List<String> filteredFilmIds;
    if (!query.isEmpty) {
      final filmTuples =
          filmIds.map((id) => Tuple2<String, Film>(id, filmMap![id]!)).toList();

      filteredFilmIds = filterViaQuery(
        filmIds,
        query,
        filmTuples,
      );
    } else {
      filteredFilmIds = filmIds;
    }

    if (filmIds.isEmpty) {
      return const Center(
        child: Text('You don\'t have any anime in this list'),
      );
    }

    if (filteredFilmIds.isEmpty) {
      return const Center(
        child: Text('No anime found'),
      );
    }

    return LayoutBuilder(
      builder: (context, constrains) => Scrollbar(
        controller: controller,
        isAlwaysShown: true,
        child: ReorderableListView.builder(
          scrollController: controller,
          itemCount: filteredFilmIds.length,
          padding: EdgeInsets.symmetric(
                vertical: 30,
                horizontal: max((constrains.maxWidth - 1000) / 2, 0),
              ) +
              padding,
          itemBuilder: (context, index) => ListItem(
            key: ValueKey(filteredFilmIds[index]),
            filmId: filteredFilmIds[index],
            showEpisodeTracker: showEpisodeTracker,
          ),
          onReorder: (filteredOldIndex, filteredNewIndex) {
            if (filteredOldIndex < filteredNewIndex) {
              filteredNewIndex--;
            }
            final oldIndex = filmIds.indexOf(filteredFilmIds[filteredOldIndex]);
            final newIndex = filmIds.indexOf(filteredFilmIds[filteredNewIndex]);
            ref
                .read(filmIdListProvider(name).notifier)!
                .reorder(oldIndex, newIndex);
          },
        ),
      ),
    );
  }

  List<String> filterViaQuery(
    List<String> filmIds,
    Query query,
    List<Tuple2<String, Film>> filmTuples,
  ) {
    final result = <String>[];
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
