import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/article_model.dart';
import '../utils/app_colors.dart';
import '../utils/date_formatter.dart';
import '../widgets/news_image.dart';

class DetailView extends StatelessWidget {
  const DetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final article = Get.arguments as ArticleModel;
    final isiBerita = article.content?.trim().isNotEmpty == true
        ? article.content!
        : (article.description ?? 'Ringkasan berita tidak tersedia.');

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 20, 12),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: Get.back,
                        icon: const Icon(Icons.arrow_back_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.surface,
                          side: const BorderSide(color: AppColors.border),
                          fixedSize: const Size(44, 44),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Detail berita',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (article.urlToImage != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: NewsImage(
                              url: article.urlToImage!,
                              height: 250,
                            ),
                          )
                        else
                          Container(
                            height: 190,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Icon(
                              Icons.article_rounded,
                              color: AppColors.primary,
                              size: 54,
                            ),
                          ),
                        const SizedBox(height: 22),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Text(
                            'TEKNOLOGI & INFORMASI',
                            style: TextStyle(
                              color: AppColors.primaryDark,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          article.title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 27,
                            height: 1.23,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 17),
                        Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          children: [
                            _MetaItem(
                              icon: Icons.newspaper_rounded,
                              label: article.author ?? 'Sumber berita',
                            ),
                            _MetaItem(
                              icon: Icons.calendar_today_rounded,
                              label: DateFormatter.formatDate(
                                article.publishedAt,
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 22),
                          child: Divider(color: AppColors.border),
                        ),
                        if (article.description?.isNotEmpty == true) ...[
                          Text(
                            article.description!,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              height: 1.65,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 18),
                        ],
                        Text(
                          isiBerita,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 15,
                            height: 1.85,
                          ),
                        ),
                        if (article.url != null) ...[
                          const SizedBox(height: 25),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight.withOpacity(0.55),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Sumber berita',
                                  style: TextStyle(
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                SelectableText(
                                  article.url!,
                                  style: const TextStyle(
                                    color: AppColors.primaryDark,
                                    fontSize: 12,
                                    height: 1.45,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          label,
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
