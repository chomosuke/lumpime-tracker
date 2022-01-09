import 'package:flutter/material.dart';
import 'package:frontend/states/index.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FilmActions extends HookConsumerWidget {
  final String filmId;
  const FilmActions({required this.filmId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filmIdLists = ref.watch(filmIdListsProvider);
    if (filmIdLists == null) {
      return const CircularProgressIndicator();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
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

class IconSwitch {
  final Icon filled;
  final Icon unfilled;

  const IconSwitch(this.filled, this.unfilled);
  Icon get(bool filled) => filled ? this.filled : unfilled;
}

const iconSize = 36.0;

const listNameToIcons = <String, IconSwitch>{
  toWatch: IconSwitch(
    Icon(
      Icons.watch_later,
      size: iconSize,
    ),
    Icon(
      Icons.watch_later_outlined,
      color: Colors.black38,
      size: iconSize,
    ),
  ),
  watching: IconSwitch(
    Icon(
      Icons.remove_red_eye,
      size: iconSize,
    ),
    Icon(
      Icons.remove_red_eye_outlined,
      color: Colors.black38,
      size: iconSize,
    ),
  ),
  watched: IconSwitch(
    Icon(
      Icons.done,
      size: iconSize,
    ),
    Icon(
      Icons.done,
      color: Colors.black38,
      size: iconSize,
    ),
  ),
  liked: IconSwitch(
    Icon(
      Icons.thumb_up_alt,
      size: iconSize,
    ),
    Icon(
      Icons.thumb_up_alt_outlined,
      color: Colors.black38,
      size: iconSize,
    ),
  ),
  saved: IconSwitch(
    Icon(
      Icons.bookmark,
      size: iconSize,
    ),
    Icon(
      Icons.bookmark_outline,
      color: Colors.black38,
      size: iconSize,
    ),
  ),
};
