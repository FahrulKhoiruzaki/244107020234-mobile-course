
import 'package:dio/dio.dart';

String apiErrorMessage(DioException error) {
  if (error.response?.statusCode == 401) {
    return 'Sesi telah berakhir. Silakan login kembali.';
  }

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return 'Koneksi mengalami timeout. Silakan coba lagi.';

    case DioExceptionType.connectionError:
      return 'Tidak dapat terhubung ke server. Periksa koneksi internet.';

    case DioExceptionType.badResponse:
      return 'Terjadi kesalahan pada server. Silakan coba lagi.';

    case DioExceptionType.cancel:
      return 'Permintaan dibatalkan.';

    case DioExceptionType.badCertificate:
      return 'Sertifikat keamanan server tidak valid.';

    case DioExceptionType.unknown:
      return 'Terjadi kesalahan. Silakan coba lagi.';
  }
}
