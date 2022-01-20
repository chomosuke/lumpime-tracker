import 'dart:convert';
import 'index.dart';
import 'package:http/http.dart' as http;
import 'package:http_status_code/http_status_code.dart';

Future<void> filmListPost(String key) async {
  final res = await http.post(
    apiUrl.resolve('user/filmList'),
    headers: await jsonAuthHeader(),
    body: key,
  );
  if (res.statusCode != StatusCode.OK) {
    throw Error();
  }
}

Future<List<String>> filmListsGet() async {
  final res = await http.get(
    apiUrl.resolve('user/filmLists'),
    headers: await authHeader(),
  );
  if (res.statusCode != StatusCode.OK) {
    throw Error();
  }
  return List.from(jsonDecode(res.body));
}

Future<void> filmListDelete(String key) async {
  final res = await http.delete(
    apiUrl.resolve('user/filmList/$key'),
    headers: await authHeader(),
  );
  if (res.statusCode != StatusCode.OK) {
    throw Error();
  }
}

Future<void> filmListItemPost(String key, String filmId) async {
  final res = await http.post(
    apiUrl.resolve('user/filmList/item/$key'),
    headers: await jsonAuthHeader(),
    body: filmId,
  );
  if (res.statusCode != StatusCode.OK) {
    throw Error();
  }
}

Future<List<String>?> filmListItemsGet(String key) async {
  final res = await http.get(
    apiUrl.resolve('user/filmList/items/$key'),
    headers: await authHeader(),
  );
  if (res.statusCode == StatusCode.NOT_FOUND) {
    return null;
  }
  if (res.statusCode != StatusCode.OK) {
    throw Error();
  }
  return List.from(jsonDecode(res.body));
}

Future<void> filmListItemsPut(String key, List<String> ids) async {
  final res = await http.put(
    apiUrl.resolve('user/filmList/items/$key'),
    headers: await jsonAuthHeader(),
    body: jsonEncode(ids),
  );
  if (res.statusCode != StatusCode.OK) {
    throw Error();
  }
}

Future<void> filmListItemDelete(String key, String filmId) async {
  final res = await http.delete(
    apiUrl.resolve('user/filmList/item/$key/$filmId'),
    headers: await authHeader(),
  );
  if (res.statusCode != StatusCode.OK) {
    throw Error();
  }
}
