import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:styled_widget/styled_widget.dart';

class MImage extends HookConsumerWidget {
  final double width;
  final double height;
  const MImage({
    required this.width,
    required this.height,
    Key? key,
    required this.imgUrl,
  }) : super(key: key);

  final String imgUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Image.network(
      imgUrl,
      errorBuilder: (context, error, stackTrace) => const Text('No image')
          .center()
          .constrained(
            width: width / 2,
            height: height / 2,
          )
          .decorated(border: Border.all())
          .center()
          .constrained(
            width: width,
            height: height,
          ),
      width: width,
      height: height,
      filterQuality: FilterQuality.medium,
      fit: BoxFit.contain,
    );
  }
}
