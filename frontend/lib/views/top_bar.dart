import 'package:flutter/material.dart';
import 'package:frontend/helpers/warning_dialog.dart';
import 'package:frontend/http/index.dart';
import 'package:frontend/states/index.dart';
import 'package:frontend/views/forms/change_password.dart';
import 'package:frontend/views/forms/change_username.dart';
import 'package:google_fonts/google_fonts.dart';
import 'forms/index.dart';
import 'index.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:styled_widget/styled_widget.dart';

class TopBar extends HookConsumerWidget {
  const TopBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.network(
            baseUrl.resolve('favicon.png').toString(),
            height: 56,
            filterQuality: FilterQuality.medium,
          ),
          const SizedBox(width: 20),
          if (constraints.maxWidth > 910)
            Text(
              appName,
              style: GoogleFonts.nunito(fontSize: 34, color: Colors.black54),
            ),
          const Spacer(flex: 6),
          constraints.maxWidth > 600
              ? const Search().width(400)
              : const Search().flexible(flex: 1000),
          const Spacer(flex: 1),
          constraints.maxWidth > 660
              ? const Actions().alignment(Alignment.centerRight).width(150)
              : const Actions(short: true).width(40),
        ],
      )
          .padding(vertical: 10, horizontal: 20)
          .border(color: Colors.grey, bottom: 1),
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
  final bool short;
  const Actions({this.short = false, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final username = ref.watch(usernameProvider);

    return username.when(
      loading: () => const LinearProgressIndicator(),
      error: (err, stack) => Text('Error: $stack'),
      data: (username) {
        if (username == null) {
          void onPressed() {
            showDialog(
              context: context,
              builder: (context) => const SignInUp(),
            );
          }

          return short
              ? PopupMenuButton(
                  onSelected: (value) => onPressed(),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      child: Text('Log In / Sign Up'),
                      value: '',
                    ),
                  ],
                )
              : TextButton(
                  onPressed: onPressed,
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
              if (!short)
                Text(
                  'Hi $username',
                  softWrap: false,
                  overflow: TextOverflow.fade,
                ).flexible(),
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
