import 'dart:convert';

import 'account.dart';
import 'url.dart';
import 'package:http/http.dart' as http;
import 'package:http_status_code/http_status_code.dart';

class UserFilm {
  final int uptoEpisode;
  UserFilm(this.uptoEpisode);
  toMap() => <String, dynamic>{
        'uptoEpisode': uptoEpisode,
      };
  UserFilm.fromMap(Map<String, dynamic> map) : uptoEpisode = map['uptoEpisode'];
}

Future<void> userFilmPut(String id, UserFilm userFilm) async {
  final res = await http.put(
    apiUrl.resolve('user/film/$id'),
    headers: await jsonAuthHeader(),
    body: jsonEncode(userFilm.toMap()),
  );
  if (res.statusCode != StatusCode.OK) {
    throw Error();
  }
}

Future<List<UserFilm>> userFilmGet(String id) async {
  final res = await http.get(
    apiUrl.resolve('user/film/$id'),
    headers: await authHeader(),
  );
  if (res.statusCode != StatusCode.OK) {
    throw Error();
  }
  final body = List.from(jsonDecode(res.body));
  final films = body.map((film) => UserFilm.fromMap(film)).toList();
  return films;
}

class UserData {
  final Map<String, List<String>> lists; // key: listName, value: ids
  UserData(this.lists);
  toMap() => lists;
  UserData.fromMap(Map<String, dynamic> map)
      : lists = map.map((key, value) => MapEntry(key, List.from(value)));
}

Future<void> userDataPut(UserData userData) async {
  final res = await http.put(
    apiUrl.resolve('user/data'),
    headers: await jsonAuthHeader(),
    body: jsonEncode(userData.toMap()),
  );
  if (res.statusCode != StatusCode.OK) {
    throw Error();
  }
}

Future<UserData> userDataGet() async {
  final res = await http.get(
    apiUrl.resolve('user/data'),
    headers: await authHeader(),
  );
  if (res.statusCode != StatusCode.OK) {
    throw Error();
  }
  return UserData.fromMap(jsonDecode(res.body));
}
