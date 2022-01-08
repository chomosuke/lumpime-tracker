import 'package:flutter/material.dart';
import 'package:frontend/states/index.dart';
import '../index.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class QueryPage extends HookConsumerWidget {
  const QueryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queryResult = ref.watch(queryResultProvider);

    return queryResult.when(
      loading: () => const Center(
        child: SizedBox(
          width: 500,
          child: LinearProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => Text('Error: $error'),
      data: (queryResult) => Grid(
        queryResult.filmIds,
        emptyMessage: 'No anime found',
      ),
    );
  }
}
