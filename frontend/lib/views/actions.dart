import 'package:flutter/material.dart';
import 'package:frontend/states/index.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tuple/tuple.dart';

class FilmActions extends HookConsumerWidget {
  final String filmId;
  final FilmActionStyle style;
  const FilmActions({
    Key? key,
    required this.filmId,
    required this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final username = ref.watch(usernameProvider).value;
    if (username == null) {
      return Container();
    }

    final filmIdLists = ref.watch(filmIdListsProvider);
    if (filmIdLists == null) {
      return const CircularProgressIndicator();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: listNames
          .map<Widget>(
            (listName) => FilmListButton(
              listName: listName,
              filmId: filmId,
              style: style,
            ),
          )
          .toList(),
    );
  }
}

class FilmListButton extends HookConsumerWidget {
  final String listName;
  final String filmId;
  final FilmActionStyle style;
  const FilmListButton({
    Key? key,
    required this.listName,
    required this.filmId,
    required this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final icons = listNameToIcons[listName]!;

    final filmIdLists = ref.watch(filmIdListsProvider);
    if (filmIdLists == null) {
      return const Text('filmIdLists is null');
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
        firstChild: Icon(
          icons.item1,
          color: style.unfilledColor,
          size: style.iconSize,
        ),
        secondChild: Icon(
          icons.item2,
          color: style.filledColor,
          size: style.iconSize,
        ),
        crossFadeState: filmIdList.contains(filmId)
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond,
        duration: const Duration(milliseconds: 100),
      ),
    );
  }
}

class FilmActionStyle {
  final double iconSize;
  final Color filledColor;
  final Color unfilledColor;
  const FilmActionStyle({
    required this.iconSize,
    required this.filledColor,
    required this.unfilledColor,
  });
}

const listNameToIcons = <String, Tuple2<IconData, IconData>>{
  toWatch: Tuple2(
    Icons.watch_later,
    Icons.watch_later_outlined,
  ),
  watching: Tuple2(
    Icons.remove_red_eye,
    Icons.remove_red_eye_outlined,
  ),
  watched: Tuple2(
    Icons.done,
    Icons.done,
  ),
  favorite: Tuple2(
    Icons.favorite,
    Icons.favorite_outline,
  ),
};
