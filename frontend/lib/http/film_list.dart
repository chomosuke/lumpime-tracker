import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

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

Future<void> previousFuture = Future.value();

Future<void> filmListItemPost(String key, String filmId) async {
  await previousFuture;
  final future = http.post(
    apiUrl.resolve('user/filmList/item/$key'),
    headers: await jsonAuthHeader(),
    body: filmId,
  );
  previousFuture = future;
  final res = await future;
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
  await previousFuture;
  final future = http.delete(
    apiUrl.resolve('user/filmList/item/$key/$filmId'),
    headers: await authHeader(),
  );
  previousFuture = future;
  final res = await future;
  if (res.statusCode != StatusCode.OK) {
    throw Error();
  }
}
