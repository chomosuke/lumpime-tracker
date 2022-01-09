import 'package:frontend/http/index.dart' as http;
import 'package:hooks_riverpod/hooks_riverpod.dart';

final accountProvider = StateNotifierProvider<Account, Future<AccountData?>>(
  (ref) {
    return Account.get();
  },
);

final accountDataProvider = FutureProvider<AccountData?>(
  (ref) async => ref.watch(accountProvider),
);

// all futures sit within the ChangeNotifier, rest is just datastructure and helpers
class Account extends StateNotifier<Future<AccountData?>> {
  Account.get()
      : super((() async {
          final username = await http.username();
          if (username == null) {
            return null;
          }
          return AccountData(username, await FilmIdLists._get());
        })());

  void login(String username, String password) {
    state = (() async {
      final success = await http.login(username, password);
      if (!success) {
        return null;
      }
      return AccountData(username, await FilmIdLists._get());
    })();
  }

  void logout() {
    state = (() async {
      await http.logout();
      return null;
    })();
  }

  void register(String username, String password) {
    state = (() async {
      final success = await http.register(username, password);
      if (!success) {
        return null;
      }
      return AccountData(username, await FilmIdLists._get());
    })();
  }

  void patch({String? username, String? password}) {
    state = (() async {
      final success = await http.accountPatch(username, password);
      if (!success) {
        return state;
      }
      return AccountData(
        username ?? (await state)!.username,
        (await state)!.filmIdLists,
      );
    })();
  }

  void addToFilmList(String listName, String filmId) {
    state = (() async {
      final accountData = (await state)!;
      final filmIdLists = accountData.filmIdLists;
      filmIdLists._lists[listName]!._add(filmId);
      filmIdLists._put();
      return AccountData(accountData.username, filmIdLists);
    })();
  }

  void removeFromFilmList(String listName, String filmId) {
    state = (() async {
      final accountData = (await state)!;
      final filmIdLists = accountData.filmIdLists;
      filmIdLists._lists[listName]!._remove(filmId);
      filmIdLists._put();
      return AccountData(accountData.username, filmIdLists);
    })();
  }

  void removeFromFilmListAt(String listName, int index) {
    state = (() async {
      final accountData = (await state)!;
      final filmIdLists = accountData.filmIdLists;
      filmIdLists._lists[listName]!._removeAt(index);
      filmIdLists._put();
      return AccountData(accountData.username, filmIdLists);
    })();
  }
}

class AccountData {
  String username;
  FilmIdLists filmIdLists;
  AccountData(this.username, this.filmIdLists);
}

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
class FilmIdLists {
  final Map<String, FilmIdList> _lists;

  Map<String, List<String>> _toListsMap() => _lists
      .map((key, value) => MapEntry<String, List<String>>(key, value.list));

  FilmIdLists._fromListsMap(Map<String, List<String>> mapLists)
      : _lists = mapLists.map((key, value) =>
            MapEntry<String, FilmIdList>(key, FilmIdList._(value)));

  static Future<FilmIdLists> _get() async {
    final userData = await http.userDataGet();
    for (final name in listNames) {
      userData.lists[name] = userData.lists[name] ?? [];
    }

    return FilmIdLists._fromListsMap(userData.lists);
  }

  Future<void> _put() => http.userDataPut(http.UserData(_toListsMap()));

  FilmIdList? operator [](String key) => _lists[key];
}

class FilmIdList {
  final List<String> list;

  final Set<String> _set;
  FilmIdList._(this.list) : _set = list.toSet();

  void _add(String filmId) {
    list.add(filmId);
    _set.add(filmId);
  }

  void _remove(String filmId) {
    list.remove(filmId);
    _set.remove(filmId);
  }

  void _removeAt(int i) {
    _set.remove(list.removeAt(i));
  }

  bool contains(String filmId) {
    return _set.contains(filmId);
  }
}
