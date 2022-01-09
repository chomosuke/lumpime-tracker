import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:frontend/states/account.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ChangeUsername extends HookConsumerWidget {
  const ChangeUsername({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final username = ref.watch(usernameProvider);

    // if username changed, this means successfully changed the username
    useValueChanged<String?, void>(username.value, (oldValue, _) {
      if (oldValue != null) {
        // username changed
        Navigator.of(context).pop();
      }
    });

    final processing = username.asData == null;
    final attempted = useState(false);

    String? usernameError;
    if (attempted.value && !processing) {
      usernameError = 'username taken!';
    }

    final controller = useTextEditingController();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        width: 300,
        margin: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: 'new username',
                errorText: usernameError,
              ),
              controller: controller,
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: processing
                      ? null
                      : () {
                          ref
                              .read(accountProvider.notifier)
                              .patch(username: controller.text);
                          attempted.value = true;
                        },
                  child: const Text('Confirm'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
