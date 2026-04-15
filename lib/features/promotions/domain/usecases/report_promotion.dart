import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/promotion_repository.dart';

/// Use case para reportar una promoción
class ReportPromotion {
  final PromotionRepository repository;

  ReportPromotion(this.repository);

  /// Ejecuta el caso de uso
  ///
  /// Parámetros:
  /// - [promotionId]: ID de la promoción a reportar
  /// - [userId]: ID del usuario que reporta
  /// - [reason]: Razón del reporte
  /// - [description]: Descripción detallada del reporte (opcional)
  ///
  /// Retorna:
  /// - [Right(void)]: Si el reporte fue exitoso
  /// - [Left(Failure)]: Si ocurrió un error
  Future<Either<Failure, void>> call({
    required String promotionId,
    required String userId,
    required String reason,
    String? description,
  }) async {
    return await repository.reportPromotion(
      promotionId: promotionId,
      userId: userId,
      reason: reason,
      description: description,
    );
  }
}

// Made with Bob
