import 'package:dio/dio.dart';

import 'auth_repository.dart';
import 'token_store.dart';

Dio buildApiClient(
  TokenStore store,
  AuthRepository auth,
) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://example-campus-api.test',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final access = await store.readAccess();

        if (access != null) {
          options.headers['Authorization'] = 'Bearer $access';
        }

        handler.next(options);
      },
      onError: (e, handler) async {
        // Refresh hanya dilakukan satu kali untuk setiap request.
        if (e.response?.statusCode != 401 ||
            e.requestOptions.extra['retried'] == true) {
          return handler.next(e);
        }

        final refresh = await store.readRefresh();

        if (refresh == null || refresh.isEmpty) {
          await store.clear();
          return handler.next(e);
        }

        try {
          // Meminta access token baru.
          final renewed = await auth.refresh(refresh);

          // Menyimpan token baru.
          await store.save(
            access: renewed,
            refresh: refresh,
          );

          // Mengulang request sebelumnya satu kali.
          final options = e.requestOptions;

          options.extra['retried'] = true;
          options.headers['Authorization'] = 'Bearer $renewed';

          final retryResponse = await dio.fetch(options);

          return handler.resolve(retryResponse);
        } catch (_) {
          // Refresh gagal, hapus seluruh sesi.
          await store.clear();

          return handler.next(e);
        }
      },
    ),
  );

  return dio;
}