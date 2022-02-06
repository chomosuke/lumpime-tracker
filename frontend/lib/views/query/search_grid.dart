import 'dart:math';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:frontend/helpers/paging_controller_hook.dart';
import 'package:frontend/states/index.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'card.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:styled_widget/styled_widget.dart';

const pageSize = 100;

class SearchGrid extends HookConsumerWidget {
  final double topPadding;
  final ScrollController controller;
  const SearchGrid({
    required this.controller,
    this.topPadding = 0,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(queryProvider);

    final pagingController = usePagingController<int, String>(
      pageRequestListener: (pageKey, pagingController) async {
        final newItems =
            await QueryResult.get(query, pageKey * pageSize, pageSize);
        final isLastPage = newItems.filmIds.length < pageSize;
        if (isLastPage) {
          pagingController.appendLastPage(newItems.filmIds);
        } else {
          final nextPageKey = pageKey + 1;
          pagingController.appendPage(newItems.filmIds, nextPageKey);
        }
      },
      firstPageKey: 0,
      effectKeys: [query],
    );

    return LayoutBuilder(builder: (context, constraints) {
      const maxCrossAxisExtent = 200.0;

      final spacing =
          constraints.maxWidth < 500 ? 30 / 525 * constraints.maxWidth : 30.0;

      final SliverGridDelegate delegate;
      if (constraints.maxWidth < 525) {
        delegate = SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: cardWidth / cardHeight,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
        );
      } else if (constraints.maxWidth < 600) {
        delegate = SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: cardWidth / cardHeight,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
        );
      } else {
        delegate = SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: maxCrossAxisExtent,
          childAspectRatio: cardWidth / cardHeight,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
        );
      }

      return Scrollbar(
        controller: controller,
        isAlwaysShown: true,
        child: PagedGridView<int, String>(
          scrollController: controller,
          pagingController: pagingController,
          padding: EdgeInsets.only(
            top: spacing + topPadding,
            left: spacing,
            right: spacing,
            bottom: spacing,
          ).add(EdgeInsets.symmetric(
            horizontal: max((constraints.maxWidth - 1600) / 2, 0),
          )),
          builderDelegate: PagedChildBuilderDelegate(
            itemBuilder: (context, filmId, index) => Card(
              filmId: filmId,
            ),
            firstPageProgressIndicatorBuilder: (context) =>
                const LinearProgressIndicator().width(500).center(),
            newPageProgressIndicatorBuilder: (context) =>
                const LinearProgressIndicator().width(500).center(),
            noItemsFoundIndicatorBuilder: (context) =>
                const Text('No anime found').center(),
            // noMoreItemsIndicatorBuilder: (context) =>
            //     const Text('End of search result').center(),
          ),
          gridDelegate: delegate,
          showNoMoreItemsIndicatorAsGridChild: false,
          showNewPageProgressIndicatorAsGridChild: false,
        ),
      );
    });
  }
}
