import 'package:frontend/http/index.dart' as http;
import 'package:hooks_riverpod/hooks_riverpod.dart';

final accountProvider = StateNotifierProvider<Account, Future<String?>>(
  (ref) {
    return Account.get();
  },
);

final usernameProvider = FutureProvider<String?>(
  (ref) async => ref.watch(accountProvider),
);

class Account extends StateNotifier<Future<String?>> {
  Account.get()
      : super((() async {
          final username = await http.username();
          if (username == null) {
            return null;
          }
          return username;
        })());

  void login(String username, String password) {
    state = (() async {
      final success = await http.login(username, password);
      if (!success) {
        return null;
      }
      return username;
    })();
  }

  void logout() {
    state = (() async {
      await http.logout();
      return null;
    })();
  }

  void register(String username, String password) {
    state = (() async {
      final success = await http.register(username, password);
      if (!success) {
        return null;
      }
      return username;
    })();
  }

  void patch({String? username, String? password}) {
    final previous = state;
    state = (() async {
      final success = await http.accountPatch(username, password);
      if (!success || username == null) {
        return previous;
      }
      return username;
    })();
  }
}
