import 'package:flutter/material.dart' hide Card;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:frontend/helpers/image.dart';
import 'package:frontend/http/index.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:styled_widget/styled_widget.dart';

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
    if (film.hasData) {
      final filmData = film.data!;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          MImage(
            width: 40,
            height: 55,
            imgUrl: filmData.imgUrl,
          )
        ],
      ).padding(all: 10);
    }
    return const Center(child: CircularProgressIndicator());
  }
}
