import 'package:frontend/http/index.dart' as http;
import 'package:hooks_riverpod/hooks_riverpod.dart';

final queryProvider = StateProvider<Query>(
  (ref) => Query('', [], [], 0, 50),
);

final queryResultProvider = FutureProvider<QueryResult>(
  (ref) async => QueryResult.get(ref.watch(queryProvider)),
);

class Query {
  final String text;
  final List<int> seasons;
  final List<String> genres;
  final int start;
  final int limit;

  Query(this.text, this.seasons, this.genres, this.start, this.limit);
}

class QueryResult {
  final List<String> filmIds;
  QueryResult._(this.filmIds);
  static Future<QueryResult> get(Query query) async {
    return QueryResult._(await http.query(
      query.text,
      query.seasons,
      query.genres,
      query.start,
      query.limit,
    ));
  }
}
