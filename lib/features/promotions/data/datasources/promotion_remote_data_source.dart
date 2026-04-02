import 'dart:math' show cos, sin, asin, sqrt;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/promotion_model.dart';
import '../models/category_model.dart';
import '../models/commerce_model.dart';

/// Data source remoto para promociones con Firestore
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
}

class PromotionRemoteDataSourceImpl implements PromotionRemoteDataSource {
  final FirebaseFirestore firestore;

  PromotionRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<PromotionModel>> getPromotions({
    int? limit,
    String? lastDocumentId,
  }) async {
    try {
      Query query = firestore
          .collection('promotions')
          .orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (lastDocumentId != null) {
        final lastDoc = await firestore
            .collection('promotions')
            .doc(lastDocumentId)
            .get();
        
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      final snapshot = await query.get();
      
      // Filtrar solo promociones activas en el cliente
      return snapshot.docs
          .map((doc) => PromotionModel.fromFirestore(doc))
          .where((promotion) => promotion.isActive)
          .toList();
    } catch (e) {
      throw ServerException(message: 'Error al obtener promociones: $e');
    }
  }

  @override
  Future<PromotionModel> getPromotionById(String id) async {
    try {
      final doc = await firestore.collection('promotions').doc(id).get();

      if (!doc.exists) {
        throw ServerException(message: 'Promoción no encontrada');
      }

      return PromotionModel.fromFirestore(doc);
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
      // Calcular límites aproximados para la consulta
      // 1 grado de latitud ≈ 111 km
      // 1 grado de longitud ≈ 111 km * cos(latitud)
      final latDelta = radiusInKm / 111.0;
      final lonDelta = radiusInKm / (111.0 * cos(latitude * 0.0174533));

      final minLat = latitude - latDelta;
      final maxLat = latitude + latDelta;
      final minLon = longitude - lonDelta;
      final maxLon = longitude + lonDelta;

      Query query = firestore
          .collection('promotions');

      if (limit != null) {
        query = query.limit(limit * 2); // Obtener más para filtrar después
      }

      final snapshot = await query.get();

      // Filtrar por distancia real y solo promociones activas usando la fórmula de Haversine
      final promotions = snapshot.docs
          .map((doc) => PromotionModel.fromFirestore(doc))
          .where((promotion) {
        if (!promotion.isActive) return false;
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
      // Simplificar query para evitar índice compuesto
      // Solo filtrar por categoría, ordenar en cliente
      Query query = firestore
          .collection('promotions')
          .where('category', isEqualTo: category);

      if (limit != null) {
        query = query.limit(limit * 2); // Obtener más para ordenar después
      }

      if (lastDocumentId != null) {
        final lastDoc = await firestore
            .collection('promotions')
            .doc(lastDocumentId)
            .get();
        
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      final snapshot = await query.get();
      
      // Filtrar solo promociones activas y ordenar por fecha en el cliente
      final promotions = snapshot.docs
          .map((doc) => PromotionModel.fromFirestore(doc))
          .where((promotion) => promotion.isActive)
          .toList();
      
      // Ordenar por fecha de creación (más recientes primero)
      promotions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      // Aplicar límite si se especificó
      return limit != null ? promotions.take(limit).toList() : promotions;
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
      Query query = firestore
          .collection('promotions')
          .where('commerceId', isEqualTo: commerceId)
          .orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (lastDocumentId != null) {
        final lastDoc = await firestore
            .collection('promotions')
            .doc(lastDocumentId)
            .get();
        
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      final snapshot = await query.get();
      
      // Filtrar solo promociones activas en el cliente
      return snapshot.docs
          .map((doc) => PromotionModel.fromFirestore(doc))
          .where((promotion) => promotion.isActive)
          .toList();
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
      // Búsqueda simple por título (Firestore no soporta búsqueda full-text nativa)
      // Para producción, considerar usar Algolia o ElasticSearch
      final snapshot = await firestore
          .collection('promotions')
          .orderBy('title')
          .startAt([query])
          .endAt(['$query\uf8ff'])
          .limit(limit ?? 20)
          .get();

      // Filtrar solo promociones activas en el cliente
      return snapshot.docs
          .map((doc) => PromotionModel.fromFirestore(doc))
          .where((promotion) => promotion.isActive)
          .toList();
    } catch (e) {
      throw ServerException(message: 'Error al buscar promociones: $e');
    }
  }

  @override
  Future<PromotionModel> createPromotion({
    required PromotionModel promotion,
  }) async {
    try {
      final docRef = await firestore
          .collection('promotions')
          .add(promotion.toFirestore());

      final doc = await docRef.get();
      return PromotionModel.fromFirestore(doc);
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
      updates['updatedAt'] = Timestamp.now();

      await firestore.collection('promotions').doc(id).update(updates);

      final doc = await firestore.collection('promotions').doc(id).get();
      return PromotionModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(message: 'Error al actualizar promoción: $e');
    }
  }

  @override
  Future<void> deletePromotion(String id) async {
    try {
      await firestore.collection('promotions').doc(id).delete();
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
      final docRef = firestore.collection('promotions').doc(promotionId);

      await firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw ServerException(message: 'Promoción no encontrada');
        }

        final data = snapshot.data()!;
        final validations = data['validations'] as Map<String, dynamic>;
        final users = List<String>.from(validations['users'] ?? []);

        // Verificar si el usuario ya validó
        if (users.contains(userId)) {
          throw ServerException(
              message: 'Ya has validado esta promoción');
        }

        // Actualizar validaciones
        users.add(userId);
        final field = isPositive ? 'positive' : 'negative';
        validations[field] = (validations[field] ?? 0) + 1;
        validations['users'] = users;

        transaction.update(docRef, {
          'validations': validations,
          'updatedAt': Timestamp.now(),
        });
      });

      final doc = await docRef.get();
      return PromotionModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(message: 'Error al validar promoción: $e');
    }
  }

  @override
  Future<void> incrementViews(String promotionId) async {
    try {
      await firestore.collection('promotions').doc(promotionId).update({
        'views': FieldValue.increment(1),
      });
    } catch (e) {
      throw ServerException(
          message: 'Error al incrementar vistas: $e');
    }
  }

  @override
  Future<void> toggleSavePromotion({
    required String promotionId,
    required String userId,
    required bool isSaved,
  }) async {
    try {
      final userRef = firestore.collection('users').doc(userId);
      
      // Simplificar: solo actualizar el documento del usuario
      // No actualizar el contador en la promoción para evitar problemas de permisos
      if (isSaved) {
        // Guardar promoción - usar set con merge para crear si no existe
        await userRef.set({
          'savedPromotions': FieldValue.arrayUnion([promotionId]),
        }, SetOptions(merge: true));
      } else {
        // Quitar de guardados
        await userRef.update({
          'savedPromotions': FieldValue.arrayRemove([promotionId]),
        });
      }
    } catch (e) {
      throw ServerException(
          message: 'Error al guardar/quitar promoción: $e');
    }
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final snapshot = await firestore
          .collection('categories')
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Error al obtener categorías: $e');
    }
  }

  @override
  Future<CommerceModel> getCommerceById(String id) async {
    try {
      final doc = await firestore.collection('commerces').doc(id).get();

      if (!doc.exists) {
        throw ServerException(message: 'Comercio no encontrado');
      }

      return CommerceModel.fromFirestore(doc);
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
      final snapshot = await firestore
          .collection('commerces')
          .limit(limit ?? 100)
          .get();

      final commerces = snapshot.docs
          .map((doc) => CommerceModel.fromFirestore(doc))
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
      throw ServerException(
          message: 'Error al obtener comercios cercanos: $e');
    }
  }

  @override
  Future<List<CommerceModel>> searchCommerces({
    required String query,
    int? limit,
  }) async {
    try {
      final snapshot = await firestore
          .collection('commerces')
          .orderBy('name')
          .startAt([query])
          .endAt(['$query\uf8ff'])
          .limit(limit ?? 20)
          .get();

      return snapshot.docs
          .map((doc) => CommerceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Error al buscar comercios: $e');
    }
  }

  @override
  Stream<List<PromotionModel>> watchPromotions({int? limit}) {
    try {
      Query query = firestore
          .collection('promotions')
          .orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      return query.snapshots().map((snapshot) {
        // Filtrar solo promociones activas en el cliente
        return snapshot.docs
            .map((doc) => PromotionModel.fromFirestore(doc))
            .where((promotion) => promotion.isActive)
            .toList();
      });
    } catch (e) {
      throw ServerException(
          message: 'Error al observar promociones: $e');
    }
  }

  @override
  Stream<PromotionModel> watchPromotion(String id) {
    try {
      return firestore
          .collection('promotions')
          .doc(id)
          .snapshots()
          .map((doc) {
        if (!doc.exists) {
          throw ServerException(message: 'Promoción no encontrada');
        }
        return PromotionModel.fromFirestore(doc);
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
}

// Made with Bob