import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:frontend/helpers/header_height_hook.dart';
import 'package:frontend/helpers/measure_size.dart';
import 'package:frontend/http/index.dart';
import 'package:frontend/states/index.dart';
import 'search_grid.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:frontend/helpers/extension.dart';

class SearchPage extends HookConsumerWidget {
  final Widget? header;
  const SearchPage({this.header, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final headerInnerHeight = useState(0.0);

    final query = ref.watch(queryProvider);

    final controller = useScrollController();

    final headerHeight = useHeaderHeight(
      controller,
      headerInnerHeight.value,
      query,
    );

    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        alignment: Alignment.topLeft,
        children: [
          SearchGrid(
            controller: controller,
            topPadding: headerInnerHeight.value,
          ),
          if (header != null)
            MeasureSize(
              onChange: (size) => headerInnerHeight.value = size.height,
              child: header!,
            )
                .sizedOverflow(
                  size: Size.fromHeight(headerHeight),
                  alignment: Alignment.bottomCenter,
                )
                .clipRect()
                .width(constraints.maxWidth - 10),
        ],
      ),
    );
  }
}
