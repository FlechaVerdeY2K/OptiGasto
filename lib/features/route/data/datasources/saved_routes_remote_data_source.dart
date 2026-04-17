import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/saved_route_model.dart';

abstract class SavedRoutesRemoteDataSource {
  Future<List<SavedRouteModel>> getSavedRoutes();
  Future<SavedRouteModel> createSavedRoute(SavedRouteModel route);
  Future<SavedRouteModel> updateSavedRoute(SavedRouteModel route);
  Future<void> deleteSavedRoute(String routeId);
}

class SavedRoutesRemoteDataSourceImpl implements SavedRoutesRemoteDataSource {
  final SupabaseClient supabase;

  const SavedRoutesRemoteDataSourceImpl({required this.supabase});

  @override
  Future<List<SavedRouteModel>> getSavedRoutes() async {
    try {
      final response = await supabase
          .from('saved_routes')
          .select()
          .order('created_at', ascending: false);
      return (response as List)
          .map((e) => SavedRouteModel.fromSupabase(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<SavedRouteModel> createSavedRoute(SavedRouteModel route) async {
    try {
      final data = {
        ...route.toSupabaseInsert(),
        'user_id': supabase.auth.currentUser!.id,
      };
      final response =
          await supabase.from('saved_routes').insert(data).select().single();
      return SavedRouteModel.fromSupabase(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<SavedRouteModel> updateSavedRoute(SavedRouteModel route) async {
    try {
      final response = await supabase
          .from('saved_routes')
          .update(route.toSupabaseUpdate())
          .eq('id', route.id)
          .select()
          .single();
      return SavedRouteModel.fromSupabase(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteSavedRoute(String routeId) async {
    try {
      await supabase.from('saved_routes').delete().eq('id', routeId);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
