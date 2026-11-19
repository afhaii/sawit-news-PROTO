import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/article_model.dart';
import '../routes/app_routes.dart';
import '../services/news_api_service.dart';
import '../utils/app_colors.dart';
import '../widgets/article_card.dart';
import '../widgets/error_view.dart';

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

  /// Cache Future per kategori agar kembali ke chip lama tidak request ulang.
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
      // Error ditampilkan oleh FutureBuilder.
    }
  }

  Future<void> _bukaPencarian() async {
    final controller = TextEditingController();
    final keyword = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cari berita'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          maxLength: 200,
          decoration: const InputDecoration(
            hintText: 'Contoh: kecerdasan buatan',
            prefixIcon: Icon(Icons.search_rounded),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TeknoNews',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
            ),
            Text(
              'Berita teknologi Indonesia',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Cari berita',
            onPressed: _bukaPencarian,
            icon: const Icon(Icons.search_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryChips(),
          Expanded(
            child: FutureBuilder<List<ArticleModel>>(
              future: _futureNews,
              builder: (context, snapshot) {
                // Urutan: loading -> error -> kosong -> data.
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
                          child: Center(
                            child: Text('Belum ada berita untuk kategori ini.'),
                          ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Container(
      height: 62,
      color: AppColors.surface,
      alignment: Alignment.centerLeft,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _categories.keys.elementAt(index);
          return ChoiceChip(
            label: Text(_categories[category]!),
            selected: category == _selectedCategory,
            onSelected: (_) => _gantiKategori(category),
            selectedColor: AppColors.primaryLight,
            labelStyle: TextStyle(
              color: category == _selectedCategory
                  ? AppColors.primary
                  : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            side: BorderSide(
              color: category == _selectedCategory
                  ? AppColors.primary
                  : Colors.transparent,
            ),
          );
        },
      ),
    );
  }
}
