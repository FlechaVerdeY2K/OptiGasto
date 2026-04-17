import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../promotions/data/models/promotion_model.dart';
import '../../domain/entities/search_query_entity.dart';
import '../../domain/entities/search_result_entity.dart';

abstract class SearchRemoteDataSource {
  Future<List<SearchResultEntity>> search(
    SearchQueryEntity query, {
    double? userLat,
    double? userLng,
  });

  Future<List<String>> getSuggestions(String partialText);
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final SupabaseClient supabase;

  SearchRemoteDataSourceImpl({required this.supabase});

  @override
  Future<List<SearchResultEntity>> search(
    SearchQueryEntity query, {
    double? userLat,
    double? userLng,
  }) async {
    try {
      final filtersJson = query.filters.toJson(lat: userLat, lng: userLng);

      final response = await supabase.rpc<dynamic>(
        'search_promotions',
        params: {
          'p_query': query.text,
          'p_filters': filtersJson,
        },
      );

      final rows = response as List<dynamic>;
      return rows.map((row) {
        final json = Map<String, dynamic>.from(row as Map);
        final promotion = _promotionFromRpcRow(json);
        final score = (json['ts_rank'] as num?)?.toDouble() ?? 1.0;
        return SearchResultEntity(promotion: promotion, relevanceScore: score);
      }).toList();
    } catch (e) {
      throw ServerException(message: 'Error al buscar promociones: $e');
    }
  }

  @override
  Future<List<String>> getSuggestions(String partialText) async {
    try {
      if (partialText.trim().isEmpty) return [];

      final response = await supabase.rpc<dynamic>(
        'get_search_suggestions',
        params: {'p_partial': partialText.trim()},
      );

      final rows = response as List<dynamic>;
      return rows.map((row) => (row as Map)['suggestion'] as String).toList();
    } catch (e) {
      throw ServerException(message: 'Error al obtener sugerencias: $e');
    }
  }

  PromotionModel _promotionFromRpcRow(Map<String, dynamic> json) {
    return PromotionModel(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      commerceId: (json['commerce_id'] as String?) ?? '',
      commerceName: (json['commerce_name'] as String?) ?? '',
      category: (json['category'] as String?) ?? '',
      discount: (json['discount'] as String?) ?? '',
      originalPrice: json['original_price'] != null
          ? (json['original_price'] as num).toDouble()
          : null,
      discountedPrice: json['discounted_price'] != null
          ? (json['discounted_price'] as num).toDouble()
          : null,
      images: json['images'] != null
          ? List<String>.from(json['images'] as List)
          : [],
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      address: '',
      validUntil: json['valid_until'] != null
          ? DateTime.parse(json['valid_until'] as String)
          : DateTime.now(),
      createdBy: (json['created_by'] as String?) ?? '',
      positiveValidations: (json['positive_validations'] as num?)?.toInt() ?? 0,
      negativeValidations: (json['negative_validations'] as num?)?.toInt() ?? 0,
      validatedByUsers: json['validated_by_users'] != null
          ? List<String>.from(json['validated_by_users'] as List)
          : [],
      views: (json['views'] as num?)?.toInt() ?? 0,
      isActive: (json['is_active'] as bool?) ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }
}
