import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/article_model.dart';
import '../routes/app_routes.dart';
import '../services/news_api_service.dart';
import '../utils/app_colors.dart';
import '../widgets/article_card.dart';
import '../widgets/error_view.dart';
import '../widgets/featured_article_card.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final NewsApiService _service = NewsApiService();

  static const Map<String, String> _categories = {
    'technology': 'Teknologi',
    'science': 'Sains',
    'business': 'Bisnis',
    'general': 'Umum',
    'nation': 'Nasional',
    'sports': 'Olahraga',
  };

  String _selectedCategory = 'technology';

  /// Cache Future per kategori supaya kembali ke chip yang sama tidak
  /// memicu request API baru.
  final Map<String, Future<List<ArticleModel>>> _categoryFutures = {};
  late Future<List<ArticleModel>> _futureNews;

  @override
  void initState() {
    super.initState();
    _futureNews = _futureForCategory(_selectedCategory);
  }

  Future<List<ArticleModel>> _futureForCategory(String category) {
    return _categoryFutures.putIfAbsent(
      category,
      () => _service.getTopHeadlines(category: category),
    );
  }

  void _gantiKategori(String category) {
    if (category == _selectedCategory) return;
    setState(() {
      _selectedCategory = category;
      _futureNews = _futureForCategory(category);
    });
  }

  void _muatUlang() {
    final newFuture = _service.getTopHeadlines(category: _selectedCategory);
    setState(() {
      _categoryFutures[_selectedCategory] = newFuture;
      _futureNews = newFuture;
    });
  }

  Future<void> _onRefresh() async {
    final newFuture = _service.getTopHeadlines(category: _selectedCategory);
    setState(() {
      _categoryFutures[_selectedCategory] = newFuture;
      _futureNews = newFuture;
    });
    try {
      await newFuture;
    } catch (_) {
      // Pesan error ditampilkan oleh FutureBuilder.
    }
  }

  Future<void> _bukaPencarian() async {
    final controller = TextEditingController();
    final keyword = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Cari berita',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          maxLength: 200,
          decoration: InputDecoration(
            hintText: 'Contoh: kecerdasan buatan',
            prefixIcon: const Icon(Icons.search_rounded),
            filled: true,
            fillColor: AppColors.background,
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('Cari'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (!mounted || keyword == null || keyword.trim().isEmpty) return;
    Get.toNamed(AppRoutes.search, arguments: keyword.trim());
  }

  void _bukaDetail(ArticleModel article) {
    Get.toNamed(AppRoutes.detail, arguments: article);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              children: [
                _buildHeader(),
                _buildCategorySection(),
                Expanded(
                  child: FutureBuilder<List<ArticleModel>>(
                    future: _futureNews,
                    builder: (context, snapshot) {
                      // Empat state: loading, error, kosong, dan data.
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const _LoadingState();
                      }

                      if (snapshot.hasError) {
                        return ErrorView(
                          message: snapshot.error.toString(),
                          onRetry: _muatUlang,
                        );
                      }

                      final articles = snapshot.data ?? <ArticleModel>[];
                      if (articles.isEmpty) {
                        return _EmptyNewsState(onRefresh: _onRefresh);
                      }

                      return RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: _onRefresh,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
                          children: [
                            _buildSectionHeading(
                              'Pilihan hari ini',
                              'Berita utama',
                            ),
                            const SizedBox(height: 13),
                            FeaturedArticleCard(
                              article: articles.first,
                              onTap: () => _bukaDetail(articles.first),
                            ),
                            const SizedBox(height: 26),
                            _buildSectionHeading(
                              'Berita lainnya',
                              '${articles.length > 1 ? articles.length - 1 : 0} berita',
                            ),
                            const SizedBox(height: 13),
                            if (articles.length == 1)
                              const _NoMoreArticles()
                            else
                              ...articles.skip(1).map(
                                (article) => Padding(
                                  padding: const EdgeInsets.only(bottom: 11),
                                  child: ArticleCard(
                                    article: article,
                                    onTap: () => _bukaDetail(article),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 17, 18, 17),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.eco_rounded,
              color: AppColors.primaryDark,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SawitNews',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.7,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Berita terkini Indonesia',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: AppColors.surface,
            shape: const CircleBorder(),
            child: IconButton(
              tooltip: 'Cari berita',
              onPressed: _bukaPencarian,
              icon: const Icon(Icons.search_rounded),
              color: AppColors.textPrimary,
              style: IconButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
                fixedSize: const Size(46, 46),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 9),
            child: Text(
              'Jelajahi topik',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _categories.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _categories.keys.elementAt(index);
                final selected = category == _selectedCategory;
                return ChoiceChip(
                  showCheckmark: false,
                  label: Text(_categories[category]!),
                  selected: selected,
                  onSelected: (_) => _gantiKategori(category),
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  side: BorderSide(
                    color: selected ? AppColors.primary : AppColors.border,
                  ),
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeading(String title, String trailing) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 19,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
        ),
        Text(
          trailing,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 14),
          Text(
            'Sedang memuat berita...',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _EmptyNewsState extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const _EmptyNewsState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 150),
          Icon(Icons.article_outlined, size: 48, color: AppColors.primary),
          SizedBox(height: 14),
          Center(
            child: Text(
              'Belum ada berita untuk topik ini',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _NoMoreArticles extends StatelessWidget {
  const _NoMoreArticles();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.55),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Text(
        'Kamu sudah melihat berita terbaru untuk topik ini.',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.primaryDark, fontSize: 12),
      ),
    );
  }
}
