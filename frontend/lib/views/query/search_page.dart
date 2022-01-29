import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:frontend/states/index.dart';
import 'search_grid.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:styled_widget/styled_widget.dart';

class SearchPage extends HookConsumerWidget {
  const SearchPage({Key? key}) : super(key: key);

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
            loading: () => const LinearProgressIndicator().width(500).center(),
            error: (error, stackTrace) => Text('Error: $stackTrace'),
            data: (queryResult) {
              hasNext.value = queryResult.filmIds.length == queryRange.limit;
              return SearchGrid(
                queryResult.filmIds,
                padding: const EdgeInsets.only(bottom: 56, top: 72),
              );
            }),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton(
              onPressed: pageIndex > 1
                  ? () {
                      ref.read(queryRangeProvider.state).state = QueryRange(
                        queryRange.start - queryRange.limit,
                        queryRange.limit,
                      );
                    }
                  : null,
              child: const Text(
                'previous',
                style: TextStyle(color: Colors.black),
              ),
            ).width(85),
            AnimatedSwitcher(
              child: Text('   $pageIndex   ', key: ValueKey(pageIndex)),
              duration: const Duration(milliseconds: 300),
            ),
            OutlinedButton(
              onPressed: hasNext.value
                  ? () {
                      ref.read(queryRangeProvider.state).state = QueryRange(
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
            ).width(85),
          ],
        )
            .padding(all: 10)
            .decorated(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            )
            .elevation(
              16,
              borderRadius: BorderRadius.circular(10),
            )
            .padding(bottom: 28),
      ],
    );
  }
}
