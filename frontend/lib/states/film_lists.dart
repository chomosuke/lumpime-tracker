import 'package:flutter/material.dart';
import 'package:frontend/http/index.dart' as http;
import 'package:frontend/states/account.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final _filmIdListsFutureProvider = FutureProvider<FilmIdLists?>((ref) {
  final username = ref.watch(usernameProvider).value;
  if (username == null) {
    return Future.value(null);
  }

  return FilmIdLists._get();
});

final filmIdListsProvider = ChangeNotifierProvider<FilmIdLists?>((ref) {
  return ref.watch(_filmIdListsFutureProvider).value;
});

const listNames = [
  toWatch,
  watching,
  watched,
  liked,
  saved,
];

const toWatch = 'toWatch';
const watched = 'watched';
const watching = 'watching';
const liked = 'liked';
const saved = 'saved';

// everytime FilmLists is modified, put should be called.
class FilmIdLists extends ChangeNotifier {
  late final Map<String, FilmIdList> _lists;
  FilmIdLists._fromListsMap(Map<String, List<String>> mapLists) {
    _lists = mapLists.map((key, value) =>
        MapEntry<String, FilmIdList>(key, FilmIdList._(value, _notify)));
  }

  Map<String, List<String>> _toListsMap() => _lists
      .map((key, value) => MapEntry<String, List<String>>(key, value.list));

  static Future<FilmIdLists> _get() async {
    final userData = await http.userDataGet();
    for (final name in listNames) {
      userData.lists[name] = userData.lists[name] ?? [];
    }

    return FilmIdLists._fromListsMap(userData.lists);
  }

  void _notify() {
    http.userDataPut(http.UserData(_toListsMap()));
    notifyListeners();
  }

  FilmIdList? operator [](String key) => _lists[key];
}

class FilmIdList {
  final VoidCallback _notify;
  final List<String> list;
  final Set<String> _set;
  FilmIdList._(this.list, this._notify) : _set = list.toSet();

  void add(String filmId) {
    list.add(filmId);
    _set.add(filmId);
    _notify();
  }

  void remove(String filmId) {
    list.remove(filmId);
    _set.remove(filmId);
    _notify();
  }

  void removeAt(int i) {
    _set.remove(list.removeAt(i));
    _notify();
  }

  bool contains(String filmId) {
    return _set.contains(filmId);
  }

  String? operator [](int i) => list[i];
}
