import 'package:flutter/material.dart';
import 'package:frontend/http/index.dart' as http;
import 'package:frontend/states/account.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final _filmIdListFutureProvider = FutureProvider.family<FilmIdList?, String>(
  (ref, key) {
    final username = ref.watch(usernameProvider).value;
    if (username == null) {
      return Future.value(null);
    }
    return FilmIdList._get(key);
  },
);

final filmIdListProvider = ChangeNotifierProvider.family<FilmIdList?, String>(
  (ref, key) {
    return ref.watch(_filmIdListFutureProvider(key)).value;
  },
);

final filmIdListsProvider = Provider<Map<String, FilmIdList>?>((ref) {
  final filmIdLists = listNames
      .map(
        (key) => ref.watch(filmIdListProvider(key)),
      )
      .toList();

  if (filmIdLists.any((list) => list == null)) {
    return null;
  }
  return Map.fromIterable(filmIdLists.cast<FilmIdList>(), key: (e) => e.key);
});

const listNames = [
  toWatch,
  watching,
  watched,
  favorite,
];

const toWatch = 'toWatch';
const watched = 'watched';
const watching = 'watching';
const favorite = 'liked';

class FilmIdList extends ChangeNotifier {
  final String key;
  final List<String> list;
  final Set<String> _set;
  FilmIdList._(this.key, this.list) : _set = list.toSet();

  static Future<FilmIdList> _get(String key) async {
    List<String>? list = await http.filmListItemsGet(key);
    if (list == null) {
      await http.filmListPost(key);
      list = [];
    }
    return FilmIdList._(key, list);
  }

  void add(String filmId) {
    http.filmListItemPost(key, filmId);
    list.add(filmId);
    _set.add(filmId);
    notifyListeners();
  }

  void remove(String filmId) {
    if (contains(filmId)) {
      http.filmListItemDelete(key, filmId);
      list.remove(filmId);
      _set.remove(filmId);
      notifyListeners();
    }
  }

  void removeAt(int i) {
    http.filmListItemDelete(key, list[i]);
    _set.remove(list.removeAt(i));
    notifyListeners();
  }

  void reorder(int oldIndex, int newIndex) {
    final id = list.removeAt(oldIndex);
    list.insert(newIndex, id);
    http.filmListItemsPut(key, list);
    notifyListeners();
  }

  bool contains(String filmId) {
    return _set.contains(filmId);
  }

  String? operator [](int i) => list[i];
}
