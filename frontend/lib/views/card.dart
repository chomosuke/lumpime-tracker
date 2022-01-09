import 'package:flutter/material.dart' hide Card;
import 'package:flutter/material.dart' as material show Card;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:frontend/http/index.dart';
import 'package:frontend/states/index.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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

class FilmImage extends HookConsumerWidget {
  const FilmImage({
    Key? key,
    required this.imgUrl,
  }) : super(key: key);

  final String imgUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return imgUrl == ''
        ? SizedBox(
            width: 400,
            height: 400,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                width: 200,
                height: 200,
                child: const Center(
                  child: Text('No image'),
                ),
              ),
            ),
          )
        : Image.network(
            imgUrl,
            width: 400,
            height: 400,
            filterQuality: FilterQuality.medium,
            fit: BoxFit.contain,
          );
  }
}

class FilmDetails extends HookConsumerWidget {
  final Film data;
  const FilmDetails(this.data, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(180, 0, 0, 0),
            ),
          ), // 40
          Text(
            data.englishName,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ), // 72
          const Spacer(),
          Row(
            children: [],
          ),
        ],
      ),
    );
  }
}

class IconSwitch {
  final Icon filled;
  final Icon unfilled;

  const IconSwitch(this.filled, this.unfilled);
  Icon get(bool filled) => filled ? this.filled : unfilled;
}

const iconSize = 24;

const listNameToIcons = <String, IconSwitch>{
  toWatch: IconSwitch(
    Icon(Icons.watch_later),
    Icon(
      Icons.watch_later_outlined,
      color: Colors.black38,
    ),
  ),
  watching: IconSwitch(
    Icon(Icons.remove_red_eye),
    Icon(
      Icons.remove_red_eye_outlined,
      color: Colors.black38,
    ),
  ),
  watched: IconSwitch(
    Icon(Icons.done),
    Icon(
      Icons.done,
      color: Colors.black38,
    ),
  ),
  liked: IconSwitch(
    Icon(Icons.thumb_up_alt),
    Icon(
      Icons.thumb_up_alt_outlined,
      color: Colors.black38,
    ),
  ),
  saved: IconSwitch(
    Icon(Icons.bookmark),
    Icon(
      Icons.bookmark_outline,
      color: Colors.black38,
    ),
  ),
};

class FilmActions extends HookConsumerWidget {
  final String filmId;
  const FilmActions({required this.filmId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: listNames
          .map<Widget>((listName) => FilmListButton(
                listName: listName,
                filmId: filmId,
              ))
          .toList(),
    );
  }
}

class FilmListButton extends HookConsumerWidget {
  final String listName;
  final String filmId;
  const FilmListButton({
    required this.listName,
    required this.filmId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final icons = listNameToIcons[listName]!;

    final username = ref.watch(usernameProvider).value;
    if (username == null) {
      return Container();
    }

    final filmIdLists = ref.watch(filmIdListsProvider);
    if (filmIdLists == null) {
      return Container();
    }

    final filmIdList = filmIdLists[listName]!;

    return InkWell(
      onTap: () {
        final watchLists = [toWatch, watching, watched];
        if (!filmIdList.contains(filmId) && watchLists.contains(listName)) {
          for (final watchListName in watchLists) {
            filmIdLists[watchListName]!.remove(filmId);
          }
          filmIdList.add(filmId);
        } else {
          if (filmIdList.contains(filmId)) {
            filmIdList.remove(filmId);
          } else {
            filmIdList.add(filmId);
          }
        }
      },
      child: AnimatedCrossFade(
        firstChild: icons.filled,
        secondChild: icons.unfilled,
        crossFadeState: filmIdList.contains(filmId)
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond,
        duration: const Duration(milliseconds: 100),
      ),
    );
  }
}
