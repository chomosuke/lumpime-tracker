import 'package:flutter/material.dart';
import 'package:frontend/states/index.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:styled_widget/styled_widget.dart';

class SignInUp extends HookConsumerWidget {
  const SignInUp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final username = ref.watch(usernameProvider);
    final processing = username.asData == null;
    final logIn = useState(true);
    final attempted = useState(false);
    final usernameController = useTextEditingController();
    final passwordController = useTextEditingController();
    final passwordRepeatController = useTextEditingController();

    String? usernameError;
    String? passwordError;
    String? passwordRepeatError;

    if (!processing) {
      if (username.value != null) {
        // logged in already, pop the dialog
        Navigator.of(context).pop();
      } else {
        if (attempted.value) {
          // show some error
          if (logIn.value) {
            // password or username incorrect
            passwordError = 'password or username incorrect!';
          } else {
            // could be password
            if (passwordController.text == '') {
              passwordError = 'password can\'t be empty';
            } else if (passwordController.text !=
                passwordRepeatController.text) {
              passwordRepeatError = 'does not match!';
            } else {
              // then must be username conflict
              usernameError = 'username taken!';
            }
          }
        }
      }
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 25),
          TextField(
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: 'username',
              errorText: usernameError,
            ),
            controller: usernameController,
          ),
          const SizedBox(height: 25),
          TextField(
            obscureText: true,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: 'password',
              errorText: passwordError,
            ),
            controller: passwordController,
          ),
          const SizedBox(height: 25),
          if (!logIn.value)
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: 'repeat password',
                errorText: passwordRepeatError,
              ),
              controller: passwordRepeatController,
            ),
          if (!logIn.value) const SizedBox(height: 25),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: processing
                    ? null
                    : () {
                        attempted.value = true;
                        if (logIn.value) {
                          ref.read(accountProvider.notifier).login(
                                usernameController.text,
                                passwordController.text,
                              );
                        } else {
                          if (passwordController.text != '' &&
                              passwordController.text ==
                                  passwordRepeatController.text) {
                            ref.read(accountProvider.notifier).register(
                                usernameController.text,
                                passwordRepeatController.text);
                          }
                        }
                      },
                child: Text(logIn.value ? 'Log In' : 'Sign Up'),
              ),
              SizedBox.fromSize(size: const Size(0, 25)),
              OutlinedButton(
                onPressed: () {
                  logIn.value = !logIn.value;
                  attempted.value = false;
                  usernameController.clear();
                  passwordController.clear();
                  passwordRepeatController.clear();
                },
                child: Text(
                  logIn.value ? 'Sign Up instead' : 'Log In instead',
                ),
              ),
            ],
          ).width(200),
          const SizedBox(height: 25),
        ],
      ).width(300).padding(all: 25),
    );
  }
}
