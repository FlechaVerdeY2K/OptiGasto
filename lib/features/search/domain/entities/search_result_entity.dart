import 'package:equatable/equatable.dart';
import '../../../promotions/domain/entities/promotion_entity.dart';

class SearchResultEntity extends Equatable {
  final PromotionEntity promotion;
  final double relevanceScore;

  const SearchResultEntity({
    required this.promotion,
    required this.relevanceScore,
  });

  @override
  List<Object?> get props => [promotion, relevanceScore];
}
