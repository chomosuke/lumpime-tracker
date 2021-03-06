import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/views/index.dart';

const storage = FlutterSecureStorage();

void main() {
  // debugPaintSizeEnabled = true;
  runApp(const ProviderScope(child: App()));
}
