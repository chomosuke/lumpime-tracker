import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:styled_widget/styled_widget.dart';

class Filters extends HookConsumerWidget {
  const Filters({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        const Spacer(),
        DropdownSearch.multiSelection(
          mode: Mode.MENU,
          dropdownSearchDecoration: const InputDecoration(
            border: InputBorder.none,
          ),
        )
            .decorated(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            )
            .elevation(
              16,
              borderRadius: BorderRadius.circular(10),
            )
            .flexible(flex: 6),
        const Spacer(),
        DropdownSearch.multiSelection(
          mode: Mode.MENU,
          dropdownSearchDecoration: const InputDecoration(
            border: InputBorder.none,
          ),
        )
            .decorated(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            )
            .elevation(
              16,
              borderRadius: BorderRadius.circular(10),
            )
            .flexible(flex: 6),
        const Spacer(),
      ],
    ).padding(all: 15);
  }
}
