import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/promotion_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/commerce_entity.dart';
import '../../domain/repositories/promotion_repository.dart';
import '../datasources/promotion_remote_data_source.dart';
import '../models/promotion_model.dart';

/// Implementación del repositorio de promociones
class PromotionRepositoryImpl implements PromotionRepository {
  final PromotionRemoteDataSource remoteDataSource;

  PromotionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<PromotionEntity>>> getPromotions({
    int? limit,
    String? lastDocumentId,
  }) async {
    try {
      final promotions = await remoteDataSource.getPromotions(
        limit: limit,
        lastDocumentId: lastDocumentId,
      );
      return Right(promotions.map((p) => p.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, PromotionEntity>> getPromotionById(String id) async {
    try {
      final promotion = await remoteDataSource.getPromotionById(id);
      return Right(promotion.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PromotionEntity>>> getNearbyPromotions({
    required double latitude,
    required double longitude,
    required double radiusInKm,
    int? limit,
  }) async {
    try {
      final promotions = await remoteDataSource.getNearbyPromotions(
        latitude: latitude,
        longitude: longitude,
        radiusInKm: radiusInKm,
        limit: limit,
      );
      return Right(promotions.map((p) => p.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PromotionEntity>>> getPromotionsByCategory({
    required String category,
    int? limit,
    String? lastDocumentId,
  }) async {
    try {
      final promotions = await remoteDataSource.getPromotionsByCategory(
        category: category,
        limit: limit,
        lastDocumentId: lastDocumentId,
      );
      return Right(promotions.map((p) => p.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PromotionEntity>>> getPromotionsByCommerce({
    required String commerceId,
    int? limit,
    String? lastDocumentId,
  }) async {
    try {
      final promotions = await remoteDataSource.getPromotionsByCommerce(
        commerceId: commerceId,
        limit: limit,
        lastDocumentId: lastDocumentId,
      );
      return Right(promotions.map((p) => p.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PromotionEntity>>> searchPromotions({
    required String query,
    int? limit,
  }) async {
    try {
      final promotions = await remoteDataSource.searchPromotions(
        query: query,
        limit: limit,
      );
      return Right(promotions.map((p) => p.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, PromotionEntity>> createPromotion({
    required PromotionEntity promotion,
  }) async {
    try {
      final promotionModel = await remoteDataSource.createPromotion(
        promotion: PromotionModel.fromEntity(promotion),
      );
      return Right(promotionModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, PromotionEntity>> updatePromotion({
    required String id,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final promotion = await remoteDataSource.updatePromotion(
        id: id,
        updates: updates,
      );
      return Right(promotion.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePromotion(String id) async {
    try {
      await remoteDataSource.deletePromotion(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, PromotionEntity>> validatePromotion({
    required String promotionId,
    required String userId,
    required bool isPositive,
  }) async {
    try {
      final promotion = await remoteDataSource.validatePromotion(
        promotionId: promotionId,
        userId: userId,
        isPositive: isPositive,
      );
      return Right(promotion.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> incrementViews(String promotionId) async {
    try {
      await remoteDataSource.incrementViews(promotionId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleSavePromotion({
    required String promotionId,
    required String userId,
    required bool isSaved,
  }) async {
    try {
      await remoteDataSource.toggleSavePromotion(
        promotionId: promotionId,
        userId: userId,
        isSaved: isSaved,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    try {
      final categories = await remoteDataSource.getCategories();
      return Right(categories.map((c) => c.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, CommerceEntity>> getCommerceById(String id) async {
    try {
      final commerce = await remoteDataSource.getCommerceById(id);
      return Right(commerce.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CommerceEntity>>> getNearbyCommerces({
    required double latitude,
    required double longitude,
    required double radiusInKm,
    int? limit,
  }) async {
    try {
      final commerces = await remoteDataSource.getNearbyCommerces(
        latitude: latitude,
        longitude: longitude,
        radiusInKm: radiusInKm,
        limit: limit,
      );
      return Right(commerces.map((c) => c.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CommerceEntity>>> searchCommerces({
    required String query,
    int? limit,
  }) async {
    try {
      final commerces = await remoteDataSource.searchCommerces(
        query: query,
        limit: limit,
      );
      return Right(commerces.map((c) => c.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Stream<List<PromotionEntity>> watchPromotions({int? limit}) {
    try {
      return remoteDataSource
          .watchPromotions(limit: limit)
          .map((promotions) => promotions.map((p) => p.toEntity()).toList());
    } catch (e) {
      throw ServerException(message: 'Error al observar promociones: $e');
    }
  }

  @override
  Stream<PromotionEntity> watchPromotion(String id) {
    try {
      return remoteDataSource
          .watchPromotion(id)
          .map((promotion) => promotion.toEntity());
    } catch (e) {
      throw ServerException(message: 'Error al observar promoción: $e');
    }
  }

  @override
  Future<Either<Failure, List<String>>> uploadPromotionImages({
    required List<File> images,
    String? promotionId,
  }) async {
    try {
      final urls = await remoteDataSource.uploadPromotionImages(
        images: images,
        promotionId: promotionId,
      );
      return Right(urls);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> reportPromotion({
    required String promotionId,
    required String userId,
    required String reason,
    String? description,
  }) async {
    try {
      await remoteDataSource.reportPromotion(
        promotionId: promotionId,
        userId: userId,
        reason: reason,
        description: description,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }
}

// Made with Bob