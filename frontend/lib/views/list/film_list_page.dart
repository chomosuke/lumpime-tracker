import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:frontend/helpers/header_height_hook.dart';
import 'package:frontend/helpers/measure_size.dart';
import 'package:frontend/states/index.dart';
import 'package:frontend/views/filters.dart';
import 'film_list.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:frontend/helpers/extension.dart';

class FilmListPage extends HookConsumerWidget {
  final String listName;
  final Widget? header;
  const FilmListPage({
    this.header,
    required this.listName,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final username = ref.watch(usernameProvider).value;

    final headerInnerHeight = useState(0.0);

    final controller = useScrollController();

    final headerHeight = useHeaderHeight(controller, headerInnerHeight.value);

    if (username == null) {
      return const Center(
        child: Text('Log In to save anime to a list'),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        alignment: Alignment.topLeft,
        children: [
          FilmList(
            controller: controller,
            name: listName,
            showEpisodeTracker: listName == watching,
            padding: EdgeInsets.only(top: headerInnerHeight.value),
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
