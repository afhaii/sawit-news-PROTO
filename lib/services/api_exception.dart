import 'package:dio/dio.dart';

import '../config/env.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  factory ApiException.fromDio(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.transformTimeout =>
        const ApiException(
          'Koneksi terlalu lambat. Server tidak merespons tepat waktu.',
        ),
      DioExceptionType.connectionError =>
        const ApiException(
          'Tidak ada koneksi internet. Periksa jaringan Anda.',
        ),
      DioExceptionType.badCertificate =>
        const ApiException('Sertifikat keamanan server tidak valid.'),
      DioExceptionType.cancel =>
        const ApiException('Permintaan berita dibatalkan.'),
      DioExceptionType.badResponse =>
        _dariResponse(error.response),
      DioExceptionType.unknown =>
        ApiException(
          'Terjadi kesalahan tak terduga: '
          '${Env.samarkan(error.message ?? 'Tidak ada detail error')}',
        ),
    };
  }

  static ApiException _dariResponse(Response<dynamic>? response) {
    final code = response?.statusCode;
    final pesanServer = _ambilPesanServer(response?.data);

    final message = switch (code) {
      400 => 'Permintaan tidak valid. ${pesanServer ?? 'Periksa parameter pencarian.'}',
      401 => 'API key GNews salah atau tidak terdaftar.',
      403 => 'Akses ditolak. Kuota harian habis atau email GNews belum diverifikasi.',
      404 => 'Alamat endpoint berita tidak ditemukan.',
      429 => 'Terlalu banyak request. Paket gratis hanya mengizinkan 1 request per detik.',
      final status when status != null && status >= 500 =>
        'Server GNews sedang bermasalah (kode $status). Coba lagi nanti.',
      _ => 'Gagal memuat berita (kode HTTP ${code ?? 'tidak diketahui'}).',
    };

    return ApiException(message.trim(), statusCode: code);
  }

  static String? _ambilPesanServer(dynamic data) {
    if (data is! Map) return null;
    final errors = data['errors'];

    if (errors is List && errors.isNotEmpty) {
      return errors.first.toString();
    }
    if (errors is Map && errors.isNotEmpty) {
      return errors.values.first.toString();
    }
    return null;
  }

  @override
  String toString() => message;
}
