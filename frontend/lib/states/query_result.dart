import 'package:frontend/http/index.dart' as http;

class QueryResult {
  final List<String> filmIds;
  QueryResult._(this.filmIds);
  static Future<QueryResult> get(
    String query,
    List<int> seasons,
    List<String> genres,
    int start,
    int limit,
  ) async {
    return QueryResult._(await http.query(
      query,
      seasons,
      genres,
      start,
      limit,
    ));
  }
}
