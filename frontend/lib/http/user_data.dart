import 'dart:convert';

import 'account.dart';
import 'url.dart';
import 'package:http/http.dart' as http;
import 'package:http_status_code/http_status_code.dart';

class UserFilm {
  final int? uptoEpisode;
  UserFilm(this.uptoEpisode);
  toMap() => <String, dynamic>{
        'uptoEpisode': uptoEpisode,
      };
  UserFilm.fromMap(Map<String, dynamic> map) : uptoEpisode = map['uptoEpisode'];
}

var userFilmCache = <String, UserFilm>{};

Future<void> userFilmPut(String id, UserFilm userFilm) async {
  final res = await http.put(
    apiUrl.resolve('user/film/$id'),
    headers: await jsonAuthHeader(),
    body: jsonEncode(userFilm.toMap()),
  );
  if (res.statusCode != StatusCode.OK) {
    throw Error();
  }
  userFilmCache[id] = userFilm;
}

Future<UserFilm> userFilmGet(String id) async {
  if (!userFilmCache.containsKey(id)) {
    final res = await http.get(
      apiUrl.resolve('user/film/$id'),
      headers: await authHeader(),
    );
    if (res.statusCode != StatusCode.OK) {
      throw Error();
    }
    userFilmCache[id] = UserFilm.fromMap(jsonDecode(res.body));
  }
  return userFilmCache[id]!;
}

class UserData {
  final Map<String, List<String>> lists; // key: listName, value: ids
  UserData(this.lists);
  toMap() => lists;
  UserData.fromMap(Map<String, dynamic> map)
      : lists = map.map((key, value) => MapEntry(key, List.from(value)));
}

UserData? userDataCache;

Future<void> userDataPut(UserData userData) async {
  final res = await http.put(
    apiUrl.resolve('user/data'),
    headers: await jsonAuthHeader(),
    body: jsonEncode(userData.toMap()),
  );
  if (res.statusCode != StatusCode.OK) {
    throw Error();
  }
  userDataCache = userData;
}

Future<UserData> userDataGet() async {
  if (userDataCache == null) {
    final res = await http.get(
      apiUrl.resolve('user/data'),
      headers: await authHeader(),
    );
    if (res.statusCode != StatusCode.OK) {
      throw Error();
    }
    userDataCache = UserData.fromMap(jsonDecode(res.body));
  }
  return userDataCache!;
}
