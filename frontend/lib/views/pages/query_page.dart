import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:frontend/states/index.dart';
import '../index.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class QueryPage extends HookConsumerWidget {
  const QueryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queryResult = ref.watch(queryResultProvider);
    final queryRange = ref.watch(queryRangeProvider);

    final pageIndex = (queryRange.start / 50).floor() + 1;

    final hasNext = useState(false);

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        queryResult.when(
            loading: () => const Center(
                  child: SizedBox(
                    width: 500,
                    child: LinearProgressIndicator(),
                  ),
                ),
            error: (error, stackTrace) => Text('Error: $stackTrace'),
            data: (queryResult) {
              hasNext.value = queryResult.filmIds.length == queryRange.limit;
              return Grid(
                queryResult.filmIds,
                emptyMessage: 'No anime found',
                padding: const EdgeInsets.only(bottom: 56),
              );
            }),
        Container(
          margin: const EdgeInsets.only(bottom: 28),
          child: Material(
            elevation: 16,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 85,
                    child: OutlinedButton(
                      onPressed: pageIndex > 1
                          ? () {
                              ref.read(queryRangeProvider.state).state =
                                  QueryRange(
                                queryRange.start - queryRange.limit,
                                queryRange.limit,
                              );
                            }
                          : null,
                      child: const Text(
                        'previous',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  Text('   $pageIndex   '),
                  SizedBox(
                    width: 85,
                    child: OutlinedButton(
                      onPressed: hasNext.value
                          ? () {
                              ref.read(queryRangeProvider.state).state =
                                  QueryRange(
                                queryRange.start + queryRange.limit,
                                queryRange.limit,
                              );
                              hasNext.value = false;
                            }
                          : null,
                      child: const Text(
                        'next',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
