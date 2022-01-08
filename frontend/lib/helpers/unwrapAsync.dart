import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

Widget unwrapAsync<T>(AsyncValue<T> value, Widget Function(T) data) {
  return value.when(
    loading: () => const CircularProgressIndicator(),
    error: (err, stack) => Text('Error: $err'),
    data: data,
  );
}
