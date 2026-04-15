import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/promotion_repository.dart';

/// Use case para subir imágenes de promociones a Supabase Storage
class UploadPromotionImages {
  final PromotionRepository repository;

  UploadPromotionImages(this.repository);

  /// Ejecuta el caso de uso
  ///
  /// Parámetros:
  /// - [images]: Lista de archivos de imagen a subir
  /// - [promotionId]: ID de la promoción (opcional, se genera si no se proporciona)
  ///
  /// Retorna:
  /// - [Right(List<String>)]: URLs de las imágenes subidas
  /// - [Left(Failure)]: Si ocurrió un error
  Future<Either<Failure, List<String>>> call({
    required List<File> images,
    String? promotionId,
  }) async {
    return await repository.uploadPromotionImages(
      images: images,
      promotionId: promotionId,
    );
  }
}

// Made with Bob
