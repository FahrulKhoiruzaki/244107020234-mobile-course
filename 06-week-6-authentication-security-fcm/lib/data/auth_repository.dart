
class AuthSession {
  const AuthSession({
    required this.access,
    required this.refresh,
  });

  final String access;
  final String refresh;
}

class AuthRepository {
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Validasi akun mock
    if (email != 'mahasiswa@gmail.com' ||
        password != '123456') {
      throw Exception('Email atau kata sandi salah');
    }

    return const AuthSession(
      access: 'mock-access-token',
      refresh: 'mock-refresh-token',
    );
  }

  Future<String> refresh(String refreshToken) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (refreshToken != 'mock-refresh-token') {
      throw Exception('Refresh token tidak valid');
    }

    return 'mock-access-renewed';
  }
}
