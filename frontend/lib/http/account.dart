import 'dart:convert';
import 'dart:io';
import 'user_data.dart';
import 'url.dart';
import 'package:frontend/main.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:http_status_code/http_status_code.dart';

String hash(String str) => sha512.convert(utf8.encode(str)).toString();

Future<Map<String, String>> jsonAuthHeader() async {
  final header = <String, String>{};
  header.addAll(jsonHeader);
  header.addAll(await authHeader());
  return header;
}

const authKey = 'auth_token';

Future<Map<String, String>> authHeader() async => <String, String>{
      HttpHeaders.authorizationHeader: await storage.read(key: authKey) ?? '',
    };

Future<void> saveToken(String authToken) =>
    storage.write(key: authKey, value: authToken);

Future<void> logout() async {
  await storage.delete(key: authKey);
  userFilmCache = {};
  userDataCache = null;
}

Future<bool> login(String username, String password) async {
  final res = await http.post(
    apiUrl.resolve('login'),
    headers: jsonHeader,
    body: jsonEncode({
      'username': username,
      'password': hash(password),
    }),
  );
  if (res.statusCode == StatusCode.OK) {
    await saveToken(res.body);
    return true;
  }
  if (res.statusCode == StatusCode.UNAUTHORIZED) {
    return false;
  }
  throw Error();
}

Future<bool> register(String username, String password) async {
  final res = await http.post(
    apiUrl.resolve('register'),
    headers: jsonHeader,
    body: jsonEncode({
      'username': username,
      'password': hash(password),
    }),
  );
  if (res.statusCode == StatusCode.OK) {
    await saveToken(res.body);
    return true;
  }
  if (res.statusCode == StatusCode.CONFLICT) {
    return false;
  }
  throw Error();
}

Future<bool> accountPatch(String? username, String? password) async {
  final req = <String, String>{};
  if (username != null) {
    req['username'] = username;
  }
  if (password != null) {
    req['password'] = hash(password);
  }
  final res = await http.patch(
    apiUrl.resolve('user'),
    headers: await jsonAuthHeader(),
    body: jsonEncode(req),
  );
  if (res.statusCode == StatusCode.OK) {
    return true;
  }
  if (res.statusCode == StatusCode.CONFLICT) {
    return false;
  }
  throw Error();
}

Future<String?> username() async {
  final res = await http.get(
    apiUrl.resolve('username'),
    headers: await authHeader(),
  );
  if (res.statusCode == StatusCode.OK) {
    return res.body;
  }
  if (res.statusCode == StatusCode.UNAUTHORIZED) {
    return null;
  }
  throw Error();
}
