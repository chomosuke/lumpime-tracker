import 'package:frontend/http/index.dart' as http;
import 'package:hooks_riverpod/hooks_riverpod.dart';

const initQuery = Query('', [], []);
final queryProvider = StateProvider<Query>(
  (ref) => initQuery,
);

final queryResultProvider =
    FutureProvider.family<QueryResult, int>((ref, page) async {
  final query = ref.watch(queryProvider);
  return QueryResult.get(query, page * 100, 100);
});

class Query {
  final String text;
  final List<int> seasons;
  final List<String> genres;
  const Query(this.text, this.seasons, this.genres);

  bool get isEmpty => genres.isEmpty && seasons.isEmpty && text.isEmpty;
}

class QueryResult {
  final List<String> filmIds;
  QueryResult._(this.filmIds);
  static Future<QueryResult> get(Query query, start, limit) async {
    return QueryResult._(await http.query(
      query.text,
      query.seasons,
      query.genres,
      start,
      limit,
    ));
  }
}
