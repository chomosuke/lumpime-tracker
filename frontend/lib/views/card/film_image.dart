import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:styled_widget/styled_widget.dart';

class FilmImage extends HookConsumerWidget {
  const FilmImage({
    Key? key,
    required this.imgUrl,
  }) : super(key: key);

  final String imgUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return imgUrl == ''
        ? const Text('No image')
            .center()
            .constrained(
              width: 200,
              height: 200,
            )
            .decorated(border: Border.all())
            .center()
            .constrained(
              width: 400,
              height: 400,
            )
        : Image.network(
            imgUrl,
            width: 400,
            height: 400,
            filterQuality: FilterQuality.medium,
            fit: BoxFit.contain,
          );
  }
}
