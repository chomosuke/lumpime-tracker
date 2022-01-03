import 'dart:convert';

import 'url.dart';
import 'package:http/http.dart' as http;
import 'package:http_status_code/http_status_code.dart';

Future<List<String>> query(
  String query,
  List<int> seasons,
  List<String> genres,
  int start,
  int limit,
) async {
  String url = apiUrl.resolve('query').toString();
  url += '?query=' + query;
  url += '&seasons=' + seasons.join(',');
  url += '&genres=' + genres.join(',');
  url += '&start=' + start.toString();
  url += '&limit=' + limit.toString();
  final res = await http.get(Uri.parse(url));
  if (res.statusCode != StatusCode.OK) {
    throw Error();
  }
  return List.from(jsonDecode(res.body));
}

class Film {
  final String url;
  final String name;
  final List<String> altNames;
  final String imgUrl;
  final int episodes;
  final List<int> seasons;
  final List<String> genres;
  final String status;
  Film.fromMap(Map<String, dynamic> map)
      : url = map['url'],
        name = map['name'],
        altNames = List.from(map['alt_names']),
        imgUrl = map['img_url'],
        episodes = map['episodes'],
        seasons = List.from(map['seasons']),
        genres = List.from(map['genres']),
        status = map['status'];
}

final _filmCache = <String, Film>{};

Future<Film> filmGet(String id) async {
  if (!_filmCache.containsKey(id)) {
    final res = await http.get(apiUrl.resolve('film/$id'));
    if (res.statusCode != StatusCode.OK) {
      throw Error();
    }
    _filmCache[id] = Film.fromMap(jsonDecode(res.body));
  }
  return _filmCache[id]!;
}

class Meta {
  final int newestSeason;
  final List<String> genres;
  Meta.fromMap(Map<String, dynamic> map)
      : newestSeason = map['newest'],
        genres = List.from(map['genres']);
}

Meta? _meta;

Future<Meta> metaGet() async {
  if (_meta == null) {
    final res = await http.get(apiUrl.resolve('meta'));
    if (res.statusCode != StatusCode.OK) {
      throw Error();
    }
    _meta = Meta.fromMap(jsonDecode(res.body));
  }
  return _meta!;
}
