import 'package:flutter/foundation.dart';

final Uri baseUrl =
    kReleaseMode ? Uri.base.resolve('../') : Uri.parse('http://localhost/');
final Uri apiUrl = baseUrl.resolve('api/');
