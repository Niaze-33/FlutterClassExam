import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/quiz_theme.dart';
import '../../models/trivia_category.dart';
import '../../providers/category_provider.dart';
import '../../providers/quiz_provider.dart';
import '../widgets/quiz_widgets.dart';
import 'quiz_config_screen.dart';

class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({super.key});

  @override
  State<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width > 700 ? 3 : 2;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quizzical',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: kQuizText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'choose a category to focus on:',
                    style: GoogleFonts.lora(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            if (categoryProvider.state == CategoryLoadState.error &&
                categoryProvider.error != null)
              RetryBanner(
                message: categoryProvider.error!,
                onRetry: () =>
                    context.read<CategoryProvider>().loadCategories(force: true),
              ),
            Expanded(
              child: _buildBody(categoryProvider, crossAxisCount),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(CategoryProvider provider, int crossAxisCount) {
    if (provider.state == CategoryLoadState.loading ||
        provider.state == CategoryLoadState.initial) {
      return const CategorySkeletonGrid();
    }

    if (provider.state == CategoryLoadState.error && !provider.hasCache) {
      return Center(
        child: TextButton.icon(
          onPressed: () => provider.loadCategories(force: true),
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.92,
      ),
      itemCount: provider.categories.length,
      itemBuilder: (context, index) {
        final category = provider.categories[index];
        final color = kCategoryPastels[index % kCategoryPastels.length];
        return _CategoryCard(
          category: category,
          color: color,
          onTap: () {
            context.read<QuizProvider>().setCategory(
                  id: category.id,
                  name: category.name,
                );
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => QuizConfigScreen(
                  categoryId: category.id,
                  categoryName: category.name,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.color,
    required this.onTap,
  });

  final TriviaCategory category;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: Icon(
                    _iconFor(category.name),
                    size: 56,
                    color: kQuizText.withValues(alpha: 0.55),
                  ),
                ),
              ),
              Text(
                category.name.replaceFirst(RegExp(r'^Entertainment:\s*'), ''),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: kQuizText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('book')) return Icons.menu_book;
    if (lower.contains('film') || lower.contains('movie')) return Icons.movie;
    if (lower.contains('music')) return Icons.music_note;
    if (lower.contains('television') || lower.contains('tv')) {
      return Icons.tv;
    }
    if (lower.contains('video game') || lower.contains('games')) {
      return Icons.sports_esports;
    }
    if (lower.contains('board')) return Icons.extension;
    if (lower.contains('science') || lower.contains('nature')) {
      return Icons.science;
    }
    if (lower.contains('computer')) return Icons.computer;
    if (lower.contains('math')) return Icons.calculate;
    if (lower.contains('mytholog')) return Icons.auto_awesome;
    if (lower.contains('sport')) return Icons.sports_soccer;
    if (lower.contains('geograph')) return Icons.public;
    if (lower.contains('histor')) return Icons.history_edu;
    if (lower.contains('politic')) return Icons.account_balance;
    if (lower.contains('art')) return Icons.palette;
    if (lower.contains('celebrities')) return Icons.star;
    if (lower.contains('animal')) return Icons.pets;
    if (lower.contains('vehicle')) return Icons.directions_car;
    if (lower.contains('comic')) return Icons.auto_stories;
    if (lower.contains('gadget')) return Icons.phone_android;
    if (lower.contains('anime') || lower.contains('manga')) {
      return Icons.animation;
    }
    if (lower.contains('cartoon')) return Icons.animation;
    return Icons.lightbulb_outline;
  }
}
