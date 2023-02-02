import 'package:flutter/foundation.dart';
import 'dart:io';

final Uri baseUrl =
    kReleaseMode ? Uri.base.resolve('../') : Uri.parse('http://localhost:8000/');
final Uri apiUrl = baseUrl.resolve('api/');

const jsonHeader = <String, String>{
  HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
};
