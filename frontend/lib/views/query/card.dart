import 'package:flutter/material.dart' hide Card;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:frontend/helpers/image.dart';
import 'package:frontend/http/index.dart';
import 'package:frontend/states/index.dart';
import '../actions.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:styled_widget/styled_widget.dart';

const cardWidth = 160.0;
const cardHeight = 262.0;

final hoverIdProvider = StateProvider<String?>((ref) => null);

class Card extends HookConsumerWidget {
  final String filmId;
  Card({
    required this.filmId,
  }) : super(key: ValueKey<String>(filmId));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final film = useFuture(useMemoized(() => filmGet(filmId), [filmId]));

    final overlay = ref.watch(hoverIdProvider) == filmId;

    if (film.hasError) {
      return Text('Error: ${film.stackTrace}');
    }
    if (film.hasData) {
      final filmData = film.data!;
      return Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              MImage(imgUrl: filmData.imgUrl, width: cardWidth, height: 220),
              Text(
                filmData.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          if (overlay)
            Overlay(
              data: filmData,
              filmId: filmId,
            ),
        ],
      )
          .constrained(
            width: cardWidth,
            height: cardHeight,
          )
          .fittedBox()
          .gestures(
            onTap: () => ref.read(hoverIdProvider.notifier).state = filmId,
          )
          .mouseRegion(
            onEnter: (e) => ref.read(hoverIdProvider.notifier).state = filmId,
            onExit: (e) => ref.read(hoverIdProvider.notifier).state = null,
          );
    }
    return const Center(child: CircularProgressIndicator());
  }
}

class Overlay extends HookConsumerWidget {
  final Film data;
  final String filmId;
  const Overlay({
    required this.data,
    required this.filmId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const smallTextStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.bold,
      color: Colors.white54,
    );

    const smallTitleTextStlye = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: Colors.white60,
    );

    const titleTextStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Colors.white70,
    );

    final episodes = data.episodes == 0 ? '?' : data.episodes;
    final firstSeason = data.seasonsName.isEmpty ? '?' : data.seasonsName[0];

    // status, first season, episodes,
    return Column(
      children: [
        Text(
          data.name,
          textAlign: TextAlign.center,
          style: titleTextStyle,
        ),
        Text(
          data.englishName,
          textAlign: TextAlign.center,
          style: smallTitleTextStlye,
        ),
        const SizedBox(height: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              firstSeason,
              style: smallTextStyle,
            ).ripple().gestures(
              onTap: () {
                final query = ref.read(queryProvider);
                if (data.seasons.isNotEmpty &&
                    !query.seasons.contains(data.seasons[0])) {
                  ref.read(queryProvider.notifier).state = Query(
                    query.text,
                    query.seasons + [data.seasons[0]],
                    query.genres,
                  );
                }
              },
            ),
            Text(
              '${data.status} | $episodes eps',
              style: smallTextStyle,
            ),
          ],
        ),
        const SizedBox(height: 5),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: data.genres
              .map<Widget>(
                (genre) => Text(genre, style: smallTextStyle)
                    .padding(all: 2)
                    .decorated(
                      border: Border.all(color: Colors.white54),
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
                ),
              )
              .toList(),
        ),
        const Spacer(),
        FilmActions(
          filmId: filmId,
          style: const FilmActionStyle(
            iconSize: 24,
            filledColor: Colors.white38,
            unfilledColor: Colors.white,
          ),
        ),
        const SizedBox(height: 50),
      ],
    ).backgroundColor(const Color.fromRGBO(0, 0, 0, 0.64));
  }
}
