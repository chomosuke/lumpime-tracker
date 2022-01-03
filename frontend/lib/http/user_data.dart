import 'dart:convert';

import 'account.dart';
import 'url.dart';
import 'package:http/http.dart' as http;
import 'package:http_status_code/http_status_code.dart';

class UserFilmData {
  final int uptoEpisode;
  final List<String> lists;
  UserFilmData(this.uptoEpisode, this.lists);
  toMap() => <String, dynamic>{
        'uptoEpisode': uptoEpisode,
        'lists': lists,
      };
  UserFilmData.fromMap(Map<String, dynamic> map)
      : uptoEpisode = map['uptoEpisode'],
        lists = List.from(map['lists']);
}

class UserFilm {
  final String url;
  final UserFilmData data;
  UserFilm(this.url, this.data);
  toMap() => <String, dynamic>{
        'url': url,
        'data': data.toMap(),
      };
  UserFilm.fromMap(Map<String, dynamic> map)
      : url = map['url'],
        data = UserFilmData.fromMap(map['data']);
}

Future<void> userFilmPut(UserFilm userFilm) async {
  final res = await http.put(
    apiUrl.resolve('user/film'),
    headers: await jsonAuthHeader(),
    body: jsonEncode(userFilm.toMap()),
  );
  if (res.statusCode != StatusCode.OK) {
    throw Error();
  }
}

Future<List<UserFilm>> userFilmGet() async {
  final res = await http.get(
    apiUrl.resolve('user/film'),
    headers: await authHeader(),
  );
  if (res.statusCode != StatusCode.OK) {
    throw Error();
  }
  final body = List.from(jsonDecode(res.body));
  final films = body.map((film) => UserFilm.fromMap(film)).toList();
  return films;
}

Future<void> userFilmDelete(String url) async {
  final res = await http.delete(
    apiUrl.resolve('user/film'),
    headers: await jsonAuthHeader(),
    body: url,
  );
  if (res.statusCode != StatusCode.OK) {
    throw Error();
  }
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
