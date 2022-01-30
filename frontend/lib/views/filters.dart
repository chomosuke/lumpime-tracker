import 'dart:math';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:frontend/http/index.dart';
import 'package:frontend/states/index.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:styled_widget/styled_widget.dart';

class Filters extends HookConsumerWidget {
  const Filters({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(queryProvider);

    final meta = useFuture(useMemoized(metaGet));
    if (!meta.hasData) {
      return const LinearProgressIndicator().limitedBox(maxWidth: 500);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Genre',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                DropdownSearch<String>.multiSelection(
                  mode: constraints.maxWidth > 500
                      ? Mode.MENU
                      : Mode.BOTTOM_SHEET,
                  // showSelectedItems: constraints.maxWidth > 500,
                  showClearButton: true,
                  showSearchBox: true,
                  items: meta.data!.genres,
                  onChanged: (value) => ref.read(queryProvider.notifier).state =
                      Query(query.text, query.seasons, value),
                  selectedItems: query.genres,
                  dropdownSearchDecoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(10),
                  ),
                  maxHeight: min(constraints.maxHeight - 100, 1000),
                )
                    .decorated(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    )
                    .elevation(
                      16,
                      borderRadius: BorderRadius.circular(10),
                    ),
              ],
            ).flexible(flex: 6),
            const Spacer(),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Season',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                DropdownSearch<int>.multiSelection(
                  mode: constraints.maxWidth > 500
                      ? Mode.MENU
                      : Mode.BOTTOM_SHEET,
                  // showSelectedItems: constraints.maxWidth > 500,
                  showClearButton: true,
                  items: List.generate(
                    meta.data!.newestSeason + 1,
                    (i) => i,
                  ).reversed.toList(),
                  itemAsString: (i) => i == null ? '' : intToSeason(i),
                  compareFn: (item, selectedItem) => item == selectedItem,
                  onChanged: (value) => ref.read(queryProvider.notifier).state =
                      Query(query.text, value, query.genres),
                  selectedItems: query.seasons,
                  dropdownSearchDecoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(10),
                  ),
                  maxHeight: min(constraints.maxHeight - 100, 1000),
                )
                    .decorated(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    )
                    .elevation(
                      16,
                      borderRadius: BorderRadius.circular(10),
                    )
              ],
            ).flexible(flex: 6),
            const Spacer(),
          ],
        ).padding(all: 5);
        return constraints.maxWidth > 500 ? w : w.width(500).fittedBox();
      },
    );
  }
}
