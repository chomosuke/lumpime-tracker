import 'package:flutter/material.dart' hide Card;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:frontend/helpers/image.dart';
import 'package:frontend/http/index.dart';
import 'package:frontend/states/index.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:styled_widget/styled_widget.dart';

const cardWidth = 160.0;
const cardHeight = 266.0;

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
          if (overlay) Overlay(filmData),
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
  const Overlay(this.data, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const smallTextStyle = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.bold,
      color: Colors.white54,
    );

    const titleTextStyle = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );

    final episodes = data.episodes == 0 ? '?' : data.episodes;
    final firstSeason = data.firstSeason == '' ? '?' : data.firstSeason;

    // status, first season, episodes,
    return Column(
      children: [
        Text(
          data.englishName,
          textAlign: TextAlign.center,
          style: titleTextStyle,
        ),
        const SizedBox(height: 5),
        Text(
          '$firstSeason | ${data.status} | $episodes eps',
          textAlign: TextAlign.center,
          style: smallTextStyle,
        ),
        const SizedBox(height: 5),
        Wrap(
          spacing: 2,
          runSpacing: 2,
          alignment: WrapAlignment.center,
          children: data.genres
              .map<Widget>(
                (genre) => Text(genre, style: smallTextStyle)
                    .padding(all: 2)
                    .decorated(
                      border: Border.all(color: Colors.white54),
                      borderRadius: BorderRadius.circular(2),
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
      ],
    ).backgroundColor(Colors.black54);
  }
}
