import 'package:flutter/material.dart' hide Card;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:frontend/helpers/image.dart';
import 'package:frontend/http/index.dart';
import 'package:frontend/states/index.dart';
import 'package:frontend/views/actions.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:styled_widget/styled_widget.dart';

const smallTextStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.bold,
  color: Colors.black54,
);

const smallTitleTextStlye = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.bold,
  color: Colors.black87,
);

const titleTextStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.bold,
  color: Colors.black87,
);

class ListItem extends HookConsumerWidget {
  final String filmId;
  final bool showEpisodeTracker;
  const ListItem(
      {required this.showEpisodeTracker, required this.filmId, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filmFuture = useMemoized(() => filmGet(filmId), [filmId]);

    final film = useFuture(filmFuture);

    if (film.hasError) {
      return Text('Error: ${film.stackTrace}');
    }
    if (!film.hasData) {
      return const Center(child: CircularProgressIndicator());
    }
    final filmData = film.data!;

    final episodes = filmData.episodes == 0 ? '?' : filmData.episodes;
    final firstSeason =
        filmData.seasonsName.isEmpty ? '?' : filmData.seasonsName[0];
    return [
      MImage(
        width: 40,
        height: 60,
        imgUrl: filmData.imgUrl,
      ),
      const SizedBox(width: 5),
      [
        Text(filmData.name, style: titleTextStyle),
        [
          Text(
            firstSeason,
            style: smallTextStyle,
          ).ripple().gestures(
            onTap: () {
              final query = ref.read(queryProvider);
              if (filmData.seasons.isNotEmpty &&
                  !query.seasons.contains(filmData.seasons[0])) {
                ref.read(queryProvider.notifier).state = Query(
                  query.text,
                  query.seasons + [filmData.seasons[0]],
                  query.genres,
                );
              }
            },
          ),
          Text(
            ' | ${filmData.status} | $episodes eps',
            style: smallTextStyle,
          ),
          const SizedBox(width: 4),
          ...filmData.genres
              .map<Widget>(
                (genre) => Text(genre, style: smallTextStyle)
                    .padding(all: 2)
                    .decorated(
                      border: Border.all(color: Colors.black54),
                      borderRadius: BorderRadius.circular(4),
                    )
                    .ripple()
                    .gestures(
                  onTap: () {
                    final query = ref.read(queryProvider);
                    if (!query.genres.contains(genre)) {
                      ref.read(queryProvider.notifier).state = Query(
                        query.text,
                        query.seasons,
                        query.genres + [genre],
                      );
                    }
                  },
                ).padding(horizontal: 2),
              )
              .toList(),
          const SizedBox(width: 4),
          FilmActions(
            filmId: filmId,
            style: const FilmActionStyle(
              iconSize: 20,
              filledColor: Colors.black38,
              unfilledColor: Colors.black,
            ),
          ),
        ].toRow(),
      ].toColumn(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    ]
        .toRow(crossAxisAlignment: CrossAxisAlignment.stretch)
        .height(60)
        .padding(all: 8);
  }
}
