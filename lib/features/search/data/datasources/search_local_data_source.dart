import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/search_history_item.dart';

abstract class SearchLocalDataSource {
  Future<List<SearchHistoryItem>> getHistory();
  Future<void> saveToHistory(String query);
  Future<void> clearHistory();
}

class SearchLocalDataSourceImpl implements SearchLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const _historyKey = 'search_history';
  static const _maxHistory = 10;

  SearchLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<SearchHistoryItem>> getHistory() async {
    try {
      final jsonStr = sharedPreferences.getString(_historyKey);
      if (jsonStr == null) return [];

      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list
          .map((e) => SearchHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException(message: 'Error al leer historial: $e');
    }
  }

  @override
  Future<void> saveToHistory(String query) async {
    try {
      final trimmed = query.trim();
      if (trimmed.isEmpty) return;

      var history = await getHistory();

      // Si ya existe, moverlo al tope sin duplicar
      history.removeWhere(
        (item) => item.query.toLowerCase() == trimmed.toLowerCase(),
      );

      history.insert(
        0,
        SearchHistoryItem(query: trimmed, timestamp: DateTime.now()),
      );

      // Límite de 10 items
      if (history.length > _maxHistory) {
        history = history.sublist(0, _maxHistory);
      }

      final jsonStr = jsonEncode(history.map((e) => e.toJson()).toList());
      await sharedPreferences.setString(_historyKey, jsonStr);
    } catch (e) {
      throw CacheException(message: 'Error al guardar historial: $e');
    }
  }

  @override
  Future<void> clearHistory() async {
    try {
      await sharedPreferences.remove(_historyKey);
    } catch (e) {
      throw CacheException(message: 'Error al limpiar historial: $e');
    }
  }
}
