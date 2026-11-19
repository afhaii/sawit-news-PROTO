import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/article_model.dart';
import '../routes/app_routes.dart';
import '../services/news_api_service.dart';
import '../widgets/article_card.dart';
import '../widgets/error_view.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final NewsApiService _service = NewsApiService();
  late final String _keyword;
  late Future<List<ArticleModel>> _futureNews;

  @override
  void initState() {
    super.initState();
    _keyword = (Get.arguments as String? ?? '').trim();
    _futureNews = _service.searchNews(_keyword);
  }

  void _muatUlang() {
    setState(() {
      _futureNews = _service.searchNews(_keyword);
    });
  }

  Future<void> _onRefresh() async {
    final newFuture = _service.searchNews(_keyword);
    setState(() => _futureNews = newFuture);
    try {
      await newFuture;
    } catch (_) {
      // Error ditampilkan oleh FutureBuilder.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hasil: $_keyword',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: FutureBuilder<List<ArticleModel>>(
        future: _futureNews,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return ErrorView(
              message: snapshot.error.toString(),
              onRetry: _muatUlang,
            );
          }

          final articles = snapshot.data ?? <ArticleModel>[];
          if (articles.isEmpty) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(
                    height: 320,
                    child: Center(child: Text('Berita tidak ditemukan.')),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return ArticleCard(
                  article: article,
                  onTap: () => Get.toNamed(
                    AppRoutes.detail,
                    arguments: article,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
