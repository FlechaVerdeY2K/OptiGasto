import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/errors/failures.dart';
import '../entities/promotion_entity.dart';
import '../entities/category_entity.dart';
import '../entities/commerce_entity.dart';

/// Repositorio abstracto de promociones (capa de dominio)
abstract class PromotionRepository {
  /// Obtiene todas las promociones activas
  Future<Either<Failure, List<PromotionEntity>>> getPromotions({
    int? limit,
    String? lastDocumentId,
  });

  /// Obtiene una promoción por su ID
  Future<Either<Failure, PromotionEntity>> getPromotionById(String id);

  /// Obtiene promociones cercanas a una ubicación
  Future<Either<Failure, List<PromotionEntity>>> getNearbyPromotions({
    required double latitude,
    required double longitude,
    required double radiusInKm,
    int? limit,
  });

  /// Obtiene promociones por categoría
  Future<Either<Failure, List<PromotionEntity>>> getPromotionsByCategory({
    required String category,
    int? limit,
    String? lastDocumentId,
  });

  /// Obtiene promociones de un comercio específico
  Future<Either<Failure, List<PromotionEntity>>> getPromotionsByCommerce({
    required String commerceId,
    int? limit,
    String? lastDocumentId,
  });

  /// Busca promociones por texto
  Future<Either<Failure, List<PromotionEntity>>> searchPromotions({
    required String query,
    int? limit,
  });

  /// Crea una nueva promoción
  Future<Either<Failure, PromotionEntity>> createPromotion({
    required PromotionEntity promotion,
  });

  /// Actualiza una promoción existente
  Future<Either<Failure, PromotionEntity>> updatePromotion({
    required String id,
    required Map<String, dynamic> updates,
  });

  /// Elimina una promoción
  Future<Either<Failure, void>> deletePromotion(String id);

  /// Valida una promoción (like/dislike)
  Future<Either<Failure, PromotionEntity>> validatePromotion({
    required String promotionId,
    required String userId,
    required bool isPositive,
  });

  /// Incrementa el contador de vistas de una promoción
  Future<Either<Failure, void>> incrementViews(String promotionId);

  /// Guarda/quita una promoción de favoritos
  Future<Either<Failure, void>> toggleSavePromotion({
    required String promotionId,
    required String userId,
    required bool isSaved,
  });

  /// Obtiene todas las categorías
  Future<Either<Failure, List<CategoryEntity>>> getCategories();

  /// Obtiene un comercio por su ID
  Future<Either<Failure, CommerceEntity>> getCommerceById(String id);

  /// Obtiene comercios cercanos
  Future<Either<Failure, List<CommerceEntity>>> getNearbyCommerces({
    required double latitude,
    required double longitude,
    required double radiusInKm,
    int? limit,
  });

  /// Busca comercios por nombre o tipo
  Future<Either<Failure, List<CommerceEntity>>> searchCommerces({
    required String query,
    int? limit,
  });

  /// Stream que emite cambios en las promociones
  Stream<List<PromotionEntity>> watchPromotions({
    int? limit,
  });

  /// Stream que emite cambios en una promoción específica
  Stream<PromotionEntity> watchPromotion(String id);

  /// Sube imágenes de promoción a Supabase Storage
  Future<Either<Failure, List<String>>> uploadPromotionImages({
    required List<XFile> images,
    String? promotionId,
  });

  /// Reporta una promoción
  Future<Either<Failure, void>> reportPromotion({
    required String promotionId,
    required String userId,
    required String reason,
    String? description,
  });
}

// Made with Bob
