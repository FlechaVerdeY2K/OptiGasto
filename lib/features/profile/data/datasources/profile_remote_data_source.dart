import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../auth/data/models/user_model.dart';
import '../models/user_stats_model.dart';
import '../models/promotion_history_model.dart';

/// Interfaz para el datasource remoto de perfil
abstract class ProfileRemoteDataSource {
  Future<UserModel> getUserProfile(String userId);
  Future<UserModel> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
    String? photoUrl,
  });
  Future<String> uploadProfilePhoto({
    required String userId,
    required String filePath,
  });
  Future<UserStatsModel> getUserStats(String userId);
  Future<List<PromotionHistoryModel>> getPromotionHistory({
    required String userId,
    int? limit,
    int? offset,
  });
  Future<PromotionHistoryModel> markPromotionAsUsed({
    required String userId,
    required String promotionId,
    required double savingsAmount,
    String? notes,
  });
  Future<void> deleteHistoryEntry(String historyId);
}

/// Implementación del datasource remoto de perfil usando Supabase
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient supabase;

  ProfileRemoteDataSourceImpl({required this.supabase});

  @override
  Future<UserModel> getUserProfile(String userId) async {
    try {
      final response =
          await supabase.from('users').select().eq('id', userId).single();

      return UserModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error al obtener perfil: $e');
    }
  }

  @override
  Future<UserModel> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
    String? photoUrl,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (photoUrl != null) updateData['photo_url'] = photoUrl;

      final response = await supabase
          .from('users')
          .update(updateData)
          .eq('id', userId)
          .select()
          .single();

      return UserModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error al actualizar perfil: $e');
    }
  }

  @override
  Future<String> uploadProfilePhoto({
    required String userId,
    required String filePath,
  }) async {
    try {
      // Por ahora, retornar una URL de placeholder
      // La subida de fotos requiere configuración adicional de Storage
      // y manejo especial para web vs móvil

      // Generar un avatar placeholder basado en el userId
      final avatarUrl =
          'https://ui-avatars.com/api/?name=${Uri.encodeComponent(userId)}&size=200&background=random';

      return avatarUrl;
    } catch (e) {
      throw ServerException(message: 'Error al subir foto: $e');
    }
  }

  @override
  Future<UserStatsModel> getUserStats(String userId) async {
    try {
      final response = await supabase
          .from('user_stats')
          .select()
          .eq('user_id', userId)
          .single();

      return UserStatsModel.fromJson(response);
    } on PostgrestException catch (e) {
      // Si no existe, crear estadísticas iniciales
      if (e.code == 'PGRST116') {
        final newStats = {
          'user_id': userId,
          'total_savings': 0.0,
          'promotions_used': 0,
          'promotions_published': 0,
          'validations_given': 0,
          'reports_submitted': 0,
          'savings_by_category': {},
          'promotions_by_month': {},
          'last_updated': DateTime.now().toIso8601String(),
        };

        final response = await supabase
            .from('user_stats')
            .insert(newStats)
            .select()
            .single();

        return UserStatsModel.fromJson(response);
      }
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error al obtener estadísticas: $e');
    }
  }

  @override
  Future<List<PromotionHistoryModel>> getPromotionHistory({
    required String userId,
    int? limit,
    int? offset,
  }) async {
    try {
      var query = supabase
          .from('promotion_history')
          .select()
          .eq('user_id', userId)
          .order('used_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 10) - 1);
      }

      final response = await query;

      return (response as List)
          .map((json) => PromotionHistoryModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error al obtener historial: $e');
    }
  }

  @override
  Future<PromotionHistoryModel> markPromotionAsUsed({
    required String userId,
    required String promotionId,
    required double savingsAmount,
    String? notes,
  }) async {
    try {
      // Obtener información de la promoción
      final promotion = await supabase
          .from('promotions')
          .select('title, commerce_name, category')
          .eq('id', promotionId)
          .single();

      // Crear entrada en el historial
      final historyData = {
        'user_id': userId,
        'promotion_id': promotionId,
        'promotion_title': promotion['title'],
        'commerce_name': promotion['commerce_name'],
        'category': promotion['category'],
        'savings_amount': savingsAmount,
        'used_at': DateTime.now().toIso8601String(),
        'notes': notes,
      };

      final response = await supabase
          .from('promotion_history')
          .insert(historyData)
          .select()
          .single();

      // Actualizar estadísticas del usuario
      await _updateUserStats(userId, savingsAmount, promotion['category']);

      return PromotionHistoryModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(
          message: 'Error al marcar promoción como usada: $e');
    }
  }

  @override
  Future<void> deleteHistoryEntry(String historyId) async {
    try {
      await supabase.from('promotion_history').delete().eq('id', historyId);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error al eliminar entrada: $e');
    }
  }

  /// Actualiza las estadísticas del usuario
  Future<void> _updateUserStats(
    String userId,
    double savingsAmount,
    String category,
  ) async {
    try {
      // Obtener estadísticas actuales
      final stats = await getUserStats(userId);

      // Calcular nuevos valores
      final newTotalSavings = stats.totalSavings + savingsAmount;
      final newPromotionsUsed = stats.promotionsUsed + 1;

      // Actualizar ahorros por categoría
      final savingsByCategory =
          Map<String, double>.from(stats.savingsByCategory);
      savingsByCategory[category] =
          (savingsByCategory[category] ?? 0.0) + savingsAmount;

      // Actualizar promociones por mes
      final currentMonth = DateTime.now().toString().substring(0, 7); // YYYY-MM
      final promotionsByMonth = Map<String, int>.from(stats.promotionsByMonth);
      promotionsByMonth[currentMonth] =
          (promotionsByMonth[currentMonth] ?? 0) + 1;

      // Actualizar en la base de datos
      await supabase.from('user_stats').update({
        'total_savings': newTotalSavings,
        'promotions_used': newPromotionsUsed,
        'savings_by_category': savingsByCategory,
        'promotions_by_month': promotionsByMonth,
        'last_updated': DateTime.now().toIso8601String(),
      }).eq('user_id', userId);

      // También actualizar el campo total_savings en la tabla users
      await supabase
          .from('users')
          .update({'total_savings': newTotalSavings}).eq('id', userId);
    } catch (e) {
      // No lanzar excepción para no bloquear la operación principal
      print('Error al actualizar estadísticas: $e');
    }
  }
}

// Made with Bob
