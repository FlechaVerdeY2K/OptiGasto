import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/promotion_entity.dart';
import '../repositories/promotion_repository.dart';

/// Use case para crear una nueva promoción
class CreatePromotion {
  final PromotionRepository repository;

  CreatePromotion(this.repository);

  /// Ejecuta el caso de uso
  /// 
  /// Parámetros:
  /// - [promotion]: La promoción a crear
  /// 
  /// Retorna:
  /// - [Right(PromotionEntity)]: Si la creación fue exitosa
  /// - [Left(Failure)]: Si ocurrió un error
  Future<Either<Failure, PromotionEntity>> call({
    required PromotionEntity promotion,
  }) async {
    return await repository.createPromotion(promotion: promotion);
  }
}

// Made with Bob