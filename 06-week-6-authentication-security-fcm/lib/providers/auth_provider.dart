import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api_client.dart';
import '../data/auth_repository.dart';
import '../data/token_store.dart';

// Provider penyimpanan token.
final tokenStoreProvider = Provider<TokenStore>((ref) {
  return TokenStore();
});

// Provider repository autentikasi.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// Provider Dio.
final apiClientProvider = Provider((ref) {
  return buildApiClient(
    ref.watch(tokenStoreProvider),
    ref.watch(authRepositoryProvider),
  );
});

// Provider status autentikasi.
final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, bool>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final token = await ref
        .watch(tokenStoreProvider)
        .readAccess();

    return token != null;
  }

  // Proses login.
  Future<void> login(String email, String password) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final session = await ref
          .read(authRepositoryProvider)
          .login(
            email: email,
            password: password,
          );

      await ref.read(tokenStoreProvider).save(
            access: session.access,
            refresh: session.refresh,
          );

      return true;
    });
  }

  // Proses logout.
  Future<void> logout() async {
    await ref.read(tokenStoreProvider).clear();

    state = const AsyncData(false);
  }
}