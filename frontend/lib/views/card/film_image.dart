import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FilmImage extends HookConsumerWidget {
  const FilmImage({
    Key? key,
    required this.imgUrl,
  }) : super(key: key);

  final String imgUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return imgUrl == ''
        ? SizedBox(
            width: 400,
            height: 400,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                width: 200,
                height: 200,
                child: const Center(
                  child: Text('No image'),
                ),
              ),
            ),
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
