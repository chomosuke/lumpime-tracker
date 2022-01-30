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
  final String englishName;
  final String imgUrl;
  final int episodes;
  final List<int> seasons;
  final List<String> seasonsName;
  final List<String> genres;
  final String status;
  Film._(
    this.url,
    this.name,
    this.altNames,
    this.englishName,
    this.imgUrl,
    this.episodes,
    this.seasons,
    this.seasonsName,
    this.genres,
    this.status,
  );

  factory Film.fromMap(Map<String, dynamic> map) {
    final seasons = List<int>.from(map['seasons']);
    seasons.sort();
    final seasonsName = seasons.map<String>((s) => intToSeason(s)).toList();
    return Film._(
      map['url'],
      map['name'],
      List.from(map['alt_names']),
      map['english'],
      map['img_url'],
      map['episodes'],
      seasons,
      seasonsName,
      List.from(map['genres']),
      map['status'],
    );
  }
}

const zeroYear = 1917;

var seasonMap = [
  'Winter',
  'Spring',
  'Summer',
  'Fall',
];

String intToSeason(int i) {
  final year = (i / 4 + zeroYear).floor();
  final season = seasonMap[i % 4];
  return '$season $year';
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
