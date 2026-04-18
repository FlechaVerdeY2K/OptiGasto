import 'dart:math' show cos, sin, asin, sqrt;
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/config/supabase_config.dart';
import '../models/promotion_model.dart';
import '../models/category_model.dart';
import '../models/commerce_model.dart';

/// Data source remoto para promociones con Supabase
abstract class PromotionRemoteDataSource {
  /// Obtiene todas las promociones activas
  Future<List<PromotionModel>> getPromotions({
    int? limit,
    String? lastDocumentId,
  });

  /// Obtiene una promoción por su ID
  Future<PromotionModel> getPromotionById(String id);

  /// Obtiene promociones cercanas a una ubicación
  Future<List<PromotionModel>> getNearbyPromotions({
    required double latitude,
    required double longitude,
    required double radiusInKm,
    int? limit,
  });

  /// Obtiene promociones por categoría
  Future<List<PromotionModel>> getPromotionsByCategory({
    required String category,
    int? limit,
    String? lastDocumentId,
  });

  /// Obtiene promociones de un comercio específico
  Future<List<PromotionModel>> getPromotionsByCommerce({
    required String commerceId,
    int? limit,
    String? lastDocumentId,
  });

  /// Busca promociones por texto
  Future<List<PromotionModel>> searchPromotions({
    required String query,
    int? limit,
  });

  /// Crea una nueva promoción
  Future<PromotionModel> createPromotion({
    required PromotionModel promotion,
  });

  /// Actualiza una promoción existente
  Future<PromotionModel> updatePromotion({
    required String id,
    required Map<String, dynamic> updates,
  });

  /// Elimina una promoción
  Future<void> deletePromotion(String id);

  /// Valida una promoción (like/dislike)
  Future<PromotionModel> validatePromotion({
    required String promotionId,
    required String userId,
    required bool isPositive,
  });

  /// Incrementa el contador de vistas
  Future<void> incrementViews(String promotionId);

  /// Guarda/quita una promoción de favoritos
  Future<void> toggleSavePromotion({
    required String promotionId,
    required String userId,
    required bool isSaved,
  });

  /// Obtiene todas las categorías
  Future<List<CategoryModel>> getCategories();

  /// Obtiene un comercio por su ID
  Future<CommerceModel> getCommerceById(String id);

  /// Obtiene comercios cercanos
  Future<List<CommerceModel>> getNearbyCommerces({
    required double latitude,
    required double longitude,
    required double radiusInKm,
    int? limit,
  });

  /// Busca comercios por nombre o tipo
  Future<List<CommerceModel>> searchCommerces({
    required String query,
    int? limit,
  });

  /// Stream que emite cambios en las promociones
  Stream<List<PromotionModel>> watchPromotions({int? limit});

  /// Stream que emite cambios en una promoción específica
  Stream<PromotionModel> watchPromotion(String id);

  /// Sube imágenes de promoción a Supabase Storage
  Future<List<String>> uploadPromotionImages({
    required List<XFile> images,
    String? promotionId,
  });

  /// Reporta una promoción
  Future<void> reportPromotion({
    required String promotionId,
    required String userId,
    required String reason,
    String? description,
  });
}

class PromotionRemoteDataSourceImpl implements PromotionRemoteDataSource {
  final SupabaseClient supabase;

  PromotionRemoteDataSourceImpl({required this.supabase});

  @override
  Future<List<PromotionModel>> getPromotions({
    int? limit,
    String? lastDocumentId,
  }) async {
    try {
      var query = supabase
          .from(SupabaseConfig.promotionsTable)
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      return response.map((json) => PromotionModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException(message: 'Error al obtener promociones: $e');
    }
  }

  @override
  Future<PromotionModel> getPromotionById(String id) async {
    try {
      final response = await supabase
          .from(SupabaseConfig.promotionsTable)
          .select()
          .eq('id', id)
          .single();

      return PromotionModel.fromJson(response);
    } catch (e) {
      throw ServerException(message: 'Error al obtener promoción: $e');
    }
  }

  @override
  Future<List<PromotionModel>> getNearbyPromotions({
    required double latitude,
    required double longitude,
    required double radiusInKm,
    int? limit,
  }) async {
    try {
      // Obtener todas las promociones activas
      final query = supabase
          .from(SupabaseConfig.promotionsTable)
          .select()
          .eq('is_active', true);

      // Aplicar limit después de todas las condiciones
      final limitedQuery = limit != null ? query.limit(limit * 2) : query;

      final response = await limitedQuery;

      // Filtrar por distancia real usando la fórmula de Haversine
      final promotions = response
          .map((json) => PromotionModel.fromJson(json))
          .where((promotion) {
        final distance = _calculateDistance(
          latitude,
          longitude,
          promotion.latitude,
          promotion.longitude,
        );
        return distance <= radiusInKm;
      }).toList();

      // Ordenar por distancia
      promotions.sort((a, b) {
        final distA = _calculateDistance(
          latitude,
          longitude,
          a.latitude,
          a.longitude,
        );
        final distB = _calculateDistance(
          latitude,
          longitude,
          b.latitude,
          b.longitude,
        );
        return distA.compareTo(distB);
      });

      return limit != null ? promotions.take(limit).toList() : promotions;
    } catch (e) {
      throw ServerException(
          message: 'Error al obtener promociones cercanas: $e');
    }
  }

  @override
  Future<List<PromotionModel>> getPromotionsByCategory({
    required String category,
    int? limit,
    String? lastDocumentId,
  }) async {
    try {
      var query = supabase
          .from(SupabaseConfig.promotionsTable)
          .select()
          .eq('category', category)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      return response.map((json) => PromotionModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException(
          message: 'Error al obtener promociones por categoría: $e');
    }
  }

  @override
  Future<List<PromotionModel>> getPromotionsByCommerce({
    required String commerceId,
    int? limit,
    String? lastDocumentId,
  }) async {
    try {
      var query = supabase
          .from(SupabaseConfig.promotionsTable)
          .select()
          .eq('commerce_id', commerceId)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      return response.map((json) => PromotionModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException(
          message: 'Error al obtener promociones del comercio: $e');
    }
  }

  @override
  Future<List<PromotionModel>> searchPromotions({
    required String query,
    int? limit,
  }) async {
    try {
      // Búsqueda usando ilike (case-insensitive LIKE)
      final supabaseQuery = supabase
          .from(SupabaseConfig.promotionsTable)
          .select()
          .eq('is_active', true)
          .or('title.ilike.%$query%,description.ilike.%$query%');

      // Aplicar limit después de todas las condiciones
      final limitedQuery =
          limit != null ? supabaseQuery.limit(limit) : supabaseQuery;

      final response = await limitedQuery;

      return response.map((json) => PromotionModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException(message: 'Error al buscar promociones: $e');
    }
  }

  @override
  Future<PromotionModel> createPromotion({
    required PromotionModel promotion,
  }) async {
    try {
      final response = await supabase
          .from(SupabaseConfig.promotionsTable)
          .insert(promotion.toJson())
          .select()
          .single();

      return PromotionModel.fromJson(response);
    } catch (e) {
      throw ServerException(message: 'Error al crear promoción: $e');
    }
  }

  @override
  Future<PromotionModel> updatePromotion({
    required String id,
    required Map<String, dynamic> updates,
  }) async {
    try {
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await supabase
          .from(SupabaseConfig.promotionsTable)
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      return PromotionModel.fromJson(response);
    } catch (e) {
      throw ServerException(message: 'Error al actualizar promoción: $e');
    }
  }

  @override
  Future<void> deletePromotion(String id) async {
    try {
      await supabase.from(SupabaseConfig.promotionsTable).delete().eq('id', id);
    } catch (e) {
      throw ServerException(message: 'Error al eliminar promoción: $e');
    }
  }

  @override
  Future<PromotionModel> validatePromotion({
    required String promotionId,
    required String userId,
    required bool isPositive,
  }) async {
    try {
      // Obtener la promoción actual
      final promotion = await getPromotionById(promotionId);

      // Verificar si el usuario ya validó
      if (promotion.validatedByUsers.contains(userId)) {
        throw ServerException(message: 'Ya has validado esta promoción');
      }

      // Actualizar validaciones
      final updates = <String, dynamic>{
        'validated_by_users': [...promotion.validatedByUsers, userId],
      };

      if (isPositive) {
        updates['positive_validations'] = promotion.positiveValidations + 1;
      } else {
        updates['negative_validations'] = promotion.negativeValidations + 1;
      }

      return await updatePromotion(id: promotionId, updates: updates);
    } catch (e) {
      throw ServerException(message: 'Error al validar promoción: $e');
    }
  }

  @override
  Future<void> incrementViews(String promotionId) async {
    try {
      // Usar RPC para incrementar atómicamente
      await supabase.rpc<dynamic>('increment_promotion_views',
          params: {'promotion_id': promotionId});
    } catch (e) {
      // Si el RPC no existe, usar update manual
      try {
        final promotion = await getPromotionById(promotionId);
        await updatePromotion(
          id: promotionId,
          updates: {'views': promotion.views + 1},
        );
      } catch (e2) {
        throw ServerException(message: 'Error al incrementar vistas: $e2');
      }
    }
  }

  @override
  Future<void> toggleSavePromotion({
    required String promotionId,
    required String userId,
    required bool isSaved,
  }) async {
    try {
      if (isSaved) {
        // Guardar promoción usando upsert para evitar duplicados
        await supabase.from(SupabaseConfig.savedPromotionsTable).upsert({
          'user_id': userId,
          'promotion_id': promotionId,
          'saved_at': DateTime.now().toIso8601String(),
        }, onConflict: 'user_id,promotion_id');
      } else {
        // Quitar de guardados
        await supabase
            .from(SupabaseConfig.savedPromotionsTable)
            .delete()
            .eq('user_id', userId)
            .eq('promotion_id', promotionId);
      }
    } catch (e) {
      throw ServerException(message: 'Error al guardar/quitar promoción: $e');
    }
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await supabase
          .from(SupabaseConfig.categoriesTable)
          .select()
          .order('name');

      return response.map((json) => CategoryModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException(message: 'Error al obtener categorías: $e');
    }
  }

  @override
  Future<CommerceModel> getCommerceById(String id) async {
    try {
      final response = await supabase
          .from(SupabaseConfig.commercesTable)
          .select()
          .eq('id', id)
          .single();

      return CommerceModel.fromJson(response);
    } catch (e) {
      throw ServerException(message: 'Error al obtener comercio: $e');
    }
  }

  @override
  Future<List<CommerceModel>> getNearbyCommerces({
    required double latitude,
    required double longitude,
    required double radiusInKm,
    int? limit,
  }) async {
    try {
      final query = supabase.from(SupabaseConfig.commercesTable).select();

      // Aplicar limit después de todas las condiciones
      final limitedQuery = limit != null ? query.limit(limit * 2) : query;

      final response = await limitedQuery;

      final commerces = response
          .map((json) => CommerceModel.fromJson(json))
          .where((commerce) {
        final distance = _calculateDistance(
          latitude,
          longitude,
          commerce.latitude,
          commerce.longitude,
        );
        return distance <= radiusInKm;
      }).toList();

      // Ordenar por distancia
      commerces.sort((a, b) {
        final distA = _calculateDistance(
          latitude,
          longitude,
          a.latitude,
          a.longitude,
        );
        final distB = _calculateDistance(
          latitude,
          longitude,
          b.latitude,
          b.longitude,
        );
        return distA.compareTo(distB);
      });

      return limit != null ? commerces.take(limit).toList() : commerces;
    } catch (e) {
      throw ServerException(message: 'Error al obtener comercios cercanos: $e');
    }
  }

  @override
  Future<List<CommerceModel>> searchCommerces({
    required String query,
    int? limit,
  }) async {
    try {
      final supabaseQuery = supabase
          .from(SupabaseConfig.commercesTable)
          .select()
          .or('name.ilike.%$query%,type.ilike.%$query%');

      // Aplicar limit después de todas las condiciones
      final limitedQuery =
          limit != null ? supabaseQuery.limit(limit) : supabaseQuery;

      final response = await limitedQuery;

      return response.map((json) => CommerceModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException(message: 'Error al buscar comercios: $e');
    }
  }

  @override
  Stream<List<PromotionModel>> watchPromotions({int? limit}) {
    try {
      var query = supabase
          .from(SupabaseConfig.promotionsTable)
          .stream(primaryKey: ['id'])
          .eq('is_active', true)
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      return query.map((data) {
        return data.map((json) => PromotionModel.fromJson(json)).toList();
      });
    } catch (e) {
      throw ServerException(message: 'Error al observar promociones: $e');
    }
  }

  @override
  Stream<PromotionModel> watchPromotion(String id) {
    try {
      return supabase
          .from(SupabaseConfig.promotionsTable)
          .stream(primaryKey: ['id'])
          .eq('id', id)
          .map((data) {
            if (data.isEmpty) {
              throw ServerException(message: 'Promoción no encontrada');
            }
            return PromotionModel.fromJson(data.first);
          });
    } catch (e) {
      throw ServerException(message: 'Error al observar promoción: $e');
    }
  }

  /// Calcula la distancia entre dos puntos usando la fórmula de Haversine
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371.0; // Radio de la Tierra en km

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * 0.0174533; // pi / 180
  }

  @override
  Future<List<String>> uploadPromotionImages({
    required List<XFile> images,
    String? promotionId,
  }) async {
    try {
      final uploadedUrls = <String>[];
      const uuid = Uuid();
      final id = promotionId ?? uuid.v4();

      for (int i = 0; i < images.length; i++) {
        final xFile = images[i];
        final fileName =
            '${id}_${i}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final filePath = 'promotions/$id/$fileName';

        // XFile.readAsBytes() works on all platforms including Android content:// URIs
        final rawBytes = await xFile.readAsBytes();
        final compressedList = await _compressBytesImage(rawBytes);
        final compressedBytes = compressedList is Uint8List
            ? compressedList
            : Uint8List.fromList(compressedList);

        await supabase.storage
            .from(SupabaseConfig.promotionImagesBucket)
            .uploadBinary(
              filePath,
              compressedBytes,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: false,
                contentType: 'image/jpeg',
              ),
            );

        final publicUrl = supabase.storage
            .from(SupabaseConfig.promotionImagesBucket)
            .getPublicUrl(filePath);

        uploadedUrls.add(publicUrl);
      }

      return uploadedUrls;
    } catch (e) {
      throw ServerException(message: 'Error al subir imágenes: $e');
    }
  }

  @override
  Future<void> reportPromotion({
    required String promotionId,
    required String userId,
    required String reason,
    String? description,
  }) async {
    try {
      await supabase.from(SupabaseConfig.reportsTable).insert({
        'promotion_id': promotionId,
        'user_id': userId,
        'reason': reason,
        'description': description,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw ServerException(message: 'Error al reportar promoción: $e');
    }
  }

  /// Compresses raw image bytes. Falls back to original bytes on error.
  Future<List<int>> _compressBytesImage(List<int> rawBytes) async {
    try {
      final result = await FlutterImageCompress.compressWithList(
        rawBytes is Uint8List ? rawBytes : Uint8List.fromList(rawBytes),
        quality: 85,
        minWidth: 1920,
        minHeight: 1080,
        format: CompressFormat.jpeg,
      );
      return result;
    } catch (_) {
      return rawBytes;
    }
  }
}

// Made with Bob
