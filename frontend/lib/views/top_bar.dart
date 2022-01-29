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
          if (constraints.maxWidth > 910) ...[
            Text(
              appName,
              style: GoogleFonts.nunito(fontSize: 34),
            ),
            const SizedBox(width: 20),
          ],
          const Search().expanded(),
          const SizedBox(width: 20),
          constraints.maxWidth > 660
              ? const Actions(
                  predictedWidth: 150,
                ).alignment(Alignment.centerRight)
              : const Actions(
                  predictedWidth: 40,
                  short: true,
                ),
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
      final query = ref.read(queryProvider);
      ref.read(queryProvider.state).state = Query(
        controller.text,
        query.seasons,
        query.genres,
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
  final double predictedWidth;
  const Actions({
    required this.predictedWidth,
    this.short = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final username = ref.watch(usernameProvider);

    return username.when(
      loading: () => const LinearProgressIndicator().width(150),
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
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                );
        } else {
          return PopupMenuButton(
            child: short
                ? null
                : Text(username, style: const TextStyle(fontSize: 18)).padding(
                    horizontal: 8,
                    vertical: 6,
                  ),
            tooltip: 'Account Actions',
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
          );
        }
      },
    );
  }
}
