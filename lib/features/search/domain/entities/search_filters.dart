import 'package:equatable/equatable.dart';

enum SortBy { relevance, discount, distance, newest }

class SearchFilters extends Equatable {
  final double minDiscount;
  final List<String> categoryIds;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final double? radiusKm;
  final SortBy sortBy;

  const SearchFilters({
    this.minDiscount = 0,
    this.categoryIds = const [],
    this.dateFrom,
    this.dateTo,
    this.radiusKm,
    this.sortBy = SortBy.relevance,
  });

  SearchFilters copyWith({
    double? minDiscount,
    List<String>? categoryIds,
    DateTime? dateFrom,
    DateTime? dateTo,
    double? radiusKm,
    SortBy? sortBy,
    bool clearDateFrom = false,
    bool clearDateTo = false,
    bool clearRadiusKm = false,
  }) {
    return SearchFilters(
      minDiscount: minDiscount ?? this.minDiscount,
      categoryIds: categoryIds ?? this.categoryIds,
      dateFrom: clearDateFrom ? null : dateFrom ?? this.dateFrom,
      dateTo: clearDateTo ? null : dateTo ?? this.dateTo,
      radiusKm: clearRadiusKm ? null : radiusKm ?? this.radiusKm,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  Map<String, dynamic> toJson({double? lat, double? lng}) {
    return {
      'min_discount': minDiscount,
      'category_ids': categoryIds,
      if (dateFrom != null) 'date_from': dateFrom!.toIso8601String(),
      if (dateTo != null) 'date_to': dateTo!.toIso8601String(),
      if (radiusKm != null) 'radius_km': radiusKm,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      'sort_by': sortBy.name,
    };
  }

  bool get hasActiveFilters =>
      minDiscount > 0 ||
      categoryIds.isNotEmpty ||
      dateFrom != null ||
      dateTo != null ||
      radiusKm != null ||
      sortBy != SortBy.relevance;

  @override
  List<Object?> get props =>
      [minDiscount, categoryIds, dateFrom, dateTo, radiusKm, sortBy];
}
