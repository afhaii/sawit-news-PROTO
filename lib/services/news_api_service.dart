import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/env.dart';
import '../models/article_model.dart';
import '../models/news_response_model.dart';
import 'api_exception.dart';

class NewsApiService {
  final Dio _dio;

  NewsApiService({Dio? dio}) : _dio = dio ?? _buatDio();

  static Dio _buatDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: Env.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        queryParameters: {
          'apikey': Env.apiKey,
          'lang': 'id',
          'country': 'id',
          'max': 10,
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          responseBody: true,
          logPrint: (object) => debugPrint(Env.samarkan(object.toString())),
        ),
      );
    }

    return dio;
  }

  Future<List<ArticleModel>> getTopHeadlines({
    String category = 'technology',
  }) {
    return _ambilArtikel('/top-headlines', {'category': category});
  }

  Future<List<ArticleModel>> searchNews(String keyword) async {
    final query = keyword.trim();
    if (query.isEmpty) {
      throw const ApiException('Kata kunci pencarian tidak boleh kosong.');
    }
    if (query.length > 200) {
      throw const ApiException('Kata kunci maksimal 200 karakter.');
    }
    return _ambilArtikel('/search', {
      'q': query,
      'sortby': 'publishedAt',
    });
  }

  /// Satu pintu untuk semua request GET dan penerjemahan error.
  Future<List<ArticleModel>> _ambilArtikel(
    String path,
    Map<String, dynamic> query,
  ) async {
    if (!Env.lengkap) {
      throw const ApiException(
        'Konfigurasi belum diisi. Salin config/env.example.json menjadi '
        'config/env.json, lalu isi API key GNews.',
      );
    }

    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: query,
      );
      final data = response.data;

      if (data is! Map) {
        throw const ApiException('Format data dari server tidak dikenali.');
      }

      final json = Map<String, dynamic>.from(data);
      return NewsResponseModel.fromJson(json).articles;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    } on FormatException {
      throw const ApiException(
        'Struktur data berita dari server tidak sesuai format.',
      );
    } on TypeError {
      throw const ApiException(
        'Struktur data dari server berbeda dengan model aplikasi.',
      );
    }
  }
}
