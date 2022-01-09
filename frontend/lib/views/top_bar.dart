import 'package:flutter/material.dart';
import 'package:frontend/helpers/warning_dialog.dart';
import 'package:frontend/http/index.dart';
import 'package:frontend/states/index.dart';
import 'package:frontend/views/forms/change_password.dart';
import 'package:frontend/views/forms/change_username.dart';
import 'forms/index.dart';
import 'index.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class TopBar extends HookConsumerWidget {
  final bool search;
  const TopBar({this.search = false, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.only(
        left: 20,
        top: 10,
        right: 20,
        bottom: 10,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.network(
            baseUrl.resolve('favicon.png').toString(),
            height: 56,
            filterQuality: FilterQuality.medium,
          ),
          const SizedBox(width: 20),
          Text(
            appName,
            style: Theme.of(context).textTheme.headline4,
          ),
          const Spacer(flex: 6),
          SizedBox(
            width: 400,
            child: AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              firstChild: const Search(),
              secondChild: const SizedBox(height: 48),
              crossFadeState:
                  search ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            ),
          ),
          const Spacer(flex: 1),
          Container(
            alignment: Alignment.centerRight,
            width: 150,
            child: const Actions(),
          )
        ],
      ),
    );
  }
}

class Search extends HookConsumerWidget {
  const Search({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    void onSearch() {
      ref.read(queryProvider.state).state = Query(
        controller.text,
        [],
        [],
      );
      ref.read(queryRangeProvider.state).state = initQueryRange;
    }

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Search for an anime',
        suffixIcon: IconButton(
          icon: const Icon(Icons.search),
          onPressed: onSearch,
        ),
      ),
      onSubmitted: (value) => onSearch(),
    );
  }
}

class Actions extends HookConsumerWidget {
  const Actions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final username = ref.watch(usernameProvider);

    return username.when(
      loading: () => const LinearProgressIndicator(),
      error: (err, stack) => Text('Error: $stack'),
      data: (username) {
        if (username == null) {
          return TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const SignInUp(),
              );
            },
            child: const Text(
              'Log In / Sign Up',
              style: TextStyle(color: Colors.black),
            ),
          );
        } else {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  'Hi $username',
                  softWrap: false,
                  overflow: TextOverflow.fade,
                ),
              ),
              PopupMenuButton(
                onSelected: (value) {
                  switch (value) {
                    case 'logout':
                      showDialog(
                        context: context,
                        builder: (context) => WarningDialog(
                          title: 'Log Out',
                          description: 'Are you sure?',
                          onConfirm: () {
                            ref.read(accountProvider.notifier).logout();
                          },
                        ),
                      );
                      break;
                    case 'changeUsername':
                      showDialog(
                        context: context,
                        builder: (context) => const ChangeUsername(),
                      );
                      break;
                    case 'changePassword':
                      showDialog(
                        context: context,
                        builder: (context) => const ChangePassword(),
                      );
                      break;
                    default:
                      throw Error();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    child: Text('Log Out'),
                    value: 'logout',
                  ),
                  const PopupMenuItem(
                    child: Text('Change username'),
                    value: 'changeUsername',
                  ),
                  const PopupMenuItem(
                    child: Text('Change password'),
                    value: 'changePassword',
                  ),
                ],
              ),
            ],
          );
        }
      },
    );
  }
}
