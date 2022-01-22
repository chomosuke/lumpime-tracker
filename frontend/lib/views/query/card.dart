import 'package:flutter/material.dart' hide Card;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:frontend/helpers/image.dart';
import 'package:frontend/http/index.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:styled_widget/styled_widget.dart';

class Card extends HookConsumerWidget {
  final String filmId;
  Card({
    required this.filmId,
  }) : super(key: ValueKey<String>(filmId));

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
          MImage(imgUrl: filmData.imgUrl, width: 160, height: 220),
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
      )
          .constrained(
            width: 160,
            height: 260,
          )
          .fittedBox();
    }
    return const Center(child: CircularProgressIndicator());
  }
}

class OverLay extends HookConsumerWidget {
  final Film data;
  const OverLay(this.data, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const smallTextStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.black54,
    );

    const titleTextStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Color.fromARGB(180, 0, 0, 0),
    );

    final episodes = data.episodes == 0 ? '?' : data.episodes;
    final firstSeason = data.firstSeason == '' ? '?' : data.firstSeason;

    // status, first season, episodes,
    return Column(
      children: [
        Text(
          data.name,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          textAlign: TextAlign.center,
          style: titleTextStyle,
        ),
        Text(
          data.englishName,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          textAlign: TextAlign.center,
          style: smallTextStyle,
        ),
        const Spacer(),
        Text(
          '$firstSeason | ${data.status} | $episodes eps',
          style: smallTextStyle,
        ),
        const SizedBox(height: 5),
        Text(
          data.genres.join(' '),
          style: smallTextStyle,
        ),
      ],
    ).height(128);
  }
}
