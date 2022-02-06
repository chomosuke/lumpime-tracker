import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:frontend/http/index.dart' as http;
import 'package:hooks_riverpod/hooks_riverpod.dart';

const initQuery = Query('', [], []);
final queryProvider = StateProvider<Query>(
  (ref) => initQuery,
);

class Query {
  final String text;
  final List<int> seasons;
  final List<String> genres;
  const Query(this.text, this.seasons, this.genres);

  bool get isEmpty => genres.isEmpty && seasons.isEmpty && text.isEmpty;

  @override
  bool operator ==(Object other) {
    if (other is! Query) {
      return false;
    }
    return text == other.text &&
        listEquals(seasons, other.seasons) &&
        listEquals(genres, other.genres);
  }

  @override
  int get hashCode => Object.hash(text, hashList(seasons), hashList(genres));
}

class QueryResult {
  final List<String> filmIds;
  QueryResult._(this.filmIds);
  static Future<QueryResult> get(Query query, int start, int limit) async {
    return QueryResult._(await http.query(
      query.text,
      query.seasons,
      query.genres,
      start,
      limit,
    ));
  }
}
