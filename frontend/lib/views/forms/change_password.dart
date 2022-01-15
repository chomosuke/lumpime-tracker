import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:frontend/states/index.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:styled_widget/styled_widget.dart';

class ChangePassword extends HookConsumerWidget {
  const ChangePassword({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passwordController = useTextEditingController();
    final passwordRepeatController = useTextEditingController();

    final attempted = useState(false);

    String? passwordError;
    String? passwordRepeatError;
    if (attempted.value) {
      // means it has failed
      // display error
      if (passwordController.text == '') {
        passwordError = 'password can not be empty!';
      } else if (passwordRepeatController.text != passwordController.text) {
        passwordRepeatError = 'passwords does not match!';
      }
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          TextField(
            obscureText: true,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: 'new password',
              errorText: passwordError,
            ),
            controller: passwordController,
          ),
          const SizedBox(height: 25),
          TextField(
            obscureText: true,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: 'repeat password',
              errorText: passwordRepeatError,
            ),
            controller: passwordRepeatController,
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
                onPressed: () {
                  attempted.value = true;
                  if (passwordController.text != '' &&
                      passwordController.text ==
                          passwordRepeatController.text) {
                    ref.read(accountProvider.notifier).patch(
                          password: passwordController.text,
                        );
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Confirm'),
              ),
            ],
          ),
        ],
      ).width(300).padding(all: 25),
    );
  }
}
