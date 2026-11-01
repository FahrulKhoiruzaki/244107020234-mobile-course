
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:campus_notify/main.dart';
import 'package:campus_notify/providers/auth_provider.dart';
import 'package:campus_notify/data/token_store.dart';

void main() {
  testWidgets('Aplikasi menampilkan halaman login', (tester) async {
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(
          TokenStoreFake(),
        ),
      ],
    );

    final router = createRouter(container);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: CampusNotifyApp(router: router),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.text('Login Campus Notify'),
      findsOneWidget,
    );

    router.dispose();
    container.dispose();
  });
}

class TokenStoreFake implements TokenStore {
  @override
  Future<void> save({
    required String access,
    required String refresh,
  }) async {}

  @override
  Future<String?> readAccess() async {
    return null;
  }

  @override
  Future<String?> readRefresh() async {
    return null;
  }

  @override
  Future<void> clear() async {}
}
