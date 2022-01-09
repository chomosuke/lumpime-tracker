import 'package:flutter/material.dart';
import 'package:frontend/http/index.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FilmDetails extends HookConsumerWidget {
  final Film data;
  const FilmDetails(this.data, {Key? key}) : super(key: key);

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
    return SizedBox(
      height: 128,
      child: Column(
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
      ),
    );
  }
}
