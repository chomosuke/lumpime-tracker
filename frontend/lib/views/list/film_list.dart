import 'dart:math';
import 'package:flutter/foundation.dart';
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
  const FilmList({
    required this.name,
    this.showEpisodeTracker = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filmIds = ref.watch(filmIdListProvider(name))?.list;
    final query = ref.watch(queryProvider);

    final memorizedResult = useMemoized(
      () => filterViaQuery(filmIds ?? [], query),
      [filmIds, query],
    );
    final filteredFilmIdsSnapshot = useFuture(
      memorizedResult,
      preserveState: false,
    );

    final controller = useScrollController();

    List<String>? filteredFilmIds;
    if (filteredFilmIdsSnapshot.hasData) {
      filteredFilmIds = filteredFilmIdsSnapshot.data!;
    }

    if (filmIds == null || filteredFilmIds == null) {
      return const LinearProgressIndicator().width(500).center();
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
          itemCount: filmIds.length,
          padding: EdgeInsets.symmetric(
            vertical: 30,
            horizontal: max((constrains.maxWidth - 1600) / 2, 0),
          ),
          itemBuilder: (context, index) => ListItem(
            key: ValueKey(filmIds[index]),
            filmId: filmIds[index],
            showEpisodeTracker: showEpisodeTracker,
          ),
          onReorder: (oldIndex, newIndex) {
            ref
                .read(filmIdListProvider(name).notifier)!
                .reorder(oldIndex, newIndex);
          },
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
