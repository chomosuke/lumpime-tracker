import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class WarningDialog extends HookConsumerWidget {
  final String title;
  final String description;
  final VoidCallback onConfirm;
  const WarningDialog({
    Key? key,
    required this.title,
    required this.description,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      title: Text(title),
      content: SizedBox(width: 150, child: Text(description)),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text(
            'Confirm',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
