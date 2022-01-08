import 'package:flutter/material.dart';
import 'package:frontend/http/index.dart';
import 'package:frontend/states/index.dart';
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
            child: search ? const Search() : null,
          ),
          const Spacer(flex: 1),
          Container(
            alignment: Alignment.centerRight,
            width: 150,
            child: const AccountButton(),
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
        0,
        50,
      );
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

class AccountButton extends HookConsumerWidget {
  const AccountButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountData = ref.watch(accountDataProvider);

    return accountData.when(
      loading: () => const LinearProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
      data: (accountData) {
        if (accountData == null) {
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
          return Text('Hi ${accountData.username}');
        }
      },
    );
  }
}
