import 'package:flutter/material.dart';
import '../../../promotions/presentation/widgets/promotion_card.dart';
import '../../domain/entities/search_result_entity.dart';

class SearchResultCard extends StatelessWidget {
  final SearchResultEntity result;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;

  const SearchResultCard({
    super.key,
    required this.result,
    this.onTap,
    this.onFavorite,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return PromotionCard(
      promotion: result.promotion,
      onTap: onTap,
      onFavorite: onFavorite,
      isFavorite: isFavorite,
    );
  }
}
