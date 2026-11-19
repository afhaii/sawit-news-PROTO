class ArticleModel {
  final String title;
  final String? description;
  final String? url;
  final String? urlToImage;
  final String publishedAt;
  final String? author;
  final String? content;

  const ArticleModel({
    required this.title,
    required this.description,
    required this.url,
    required this.urlToImage,
    required this.publishedAt,
    required this.author,
    required this.content,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    final source = json['source'];
    final sourceName = source is Map ? source['name'] : null;

    return ArticleModel(
      title: _toText(json['title']) ?? 'Tanpa Judul',
      description: _toText(json['description']),
      url: _toText(json['url']),
      urlToImage: _toText(json['image']),
      publishedAt: _toText(json['publishedAt']) ?? '',
      author: _toText(sourceName),
      content: _rapikanContent(_toText(json['content'])),
    );
  }

  static String? _toText(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  /// Paket gratis GNews menambahkan penanda seperti " [988 chars]".
  static String? _rapikanContent(String? content) {
    if (content == null) return null;
    return content.replaceAll(RegExp(r'\s*\[\d+ chars\]$'), '...');
  }
}
