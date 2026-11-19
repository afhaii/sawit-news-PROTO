import 'article_model.dart';

class NewsResponseModel {
  final int totalArticles;
  final List<ArticleModel> articles;

  const NewsResponseModel({
    required this.totalArticles,
    required this.articles,
  });

  factory NewsResponseModel.fromJson(Map<String, dynamic> json) {
    final rawArticles = json['articles'];

    if (rawArticles != null && rawArticles is! List) {
      throw const FormatException('Field articles bukan berupa daftar.');
    }

    final articles = <ArticleModel>[];
    if (rawArticles is List) {
      for (final item in rawArticles) {
        if (item is! Map) {
          throw const FormatException('Salah satu artikel memiliki format tidak valid.');
        }
        articles.add(
          ArticleModel.fromJson(Map<String, dynamic>.from(item)),
        );
      }
    }

    final rawTotal = json['totalArticles'];
    final total = rawTotal is int
        ? rawTotal
        : int.tryParse(rawTotal?.toString() ?? '') ?? articles.length;

    return NewsResponseModel(
      totalArticles: total,
      articles: articles,
    );
  }
}
