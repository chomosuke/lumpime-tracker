import 'package:frontend/http/index.dart' as http;
import 'package:hooks_riverpod/hooks_riverpod.dart';

const initQuery = Query('', [], []);
final queryProvider = StateProvider<Query>(
  (ref) => initQuery,
);

final queryResultProvider = FutureProvider<QueryResult>((ref) async {
  final query = ref.watch(queryProvider);
  final queryRange = ref.watch(queryRangeProvider);
  return QueryResult.get(query, queryRange);
});

const initQueryRange = QueryRange(0, 50);
final queryRangeProvider = StateProvider(
  (ref) => initQueryRange,
);

class QueryRange {
  final int start;
  final int limit;
  const QueryRange(this.start, this.limit);
}

class Query {
  final String text;
  final List<int> seasons;
  final List<String> genres;
  const Query(this.text, this.seasons, this.genres);
}

class QueryResult {
  final List<String> filmIds;
  QueryResult._(this.filmIds);
  static Future<QueryResult> get(Query query, QueryRange queryRange) async {
    return QueryResult._(await http.query(
      query.text,
      query.seasons,
      query.genres,
      queryRange.start,
      queryRange.limit,
    ));
  }
}
