import 'package:flutter/material.dart';
import 'package:frontend/http/index.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FilmDetails extends HookConsumerWidget {
  final Film data;
  const FilmDetails(this.data, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // status, first season, episodes,
    return SizedBox(
      height: 128,
      child: Column(
        children: [
          Text(
            data.name,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(180, 0, 0, 0),
            ),
          ), // 40
          Text(
            data.englishName,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ), // 72
          const Spacer(),
          Row(
            children: [],
          ),
        ],
      ),
    );
  }
}
