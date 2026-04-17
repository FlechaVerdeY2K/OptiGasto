import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/search_history_item.dart';
import '../../domain/entities/search_query_entity.dart';
import '../../domain/entities/search_result_entity.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_local_data_source.dart';
import '../datasources/search_remote_data_source.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remoteDataSource;
  final SearchLocalDataSource localDataSource;

  SearchRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<SearchResultEntity>>> search(
    SearchQueryEntity query, {
    double? userLat,
    double? userLng,
  }) async {
    try {
      final results = await remoteDataSource.search(
        query,
        userLat: userLat,
        userLng: userLng,
      );
      return Right(results);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado al buscar: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getSuggestions(
      String partialText) async {
    try {
      final suggestions = await remoteDataSource.getSuggestions(partialText);
      return Right(suggestions);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error al obtener sugerencias: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SearchHistoryItem>>> getHistory() async {
    try {
      final history = await localDataSource.getHistory();
      return Right(history);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Error al leer historial: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveToHistory(String query) async {
    try {
      await localDataSource.saveToHistory(query);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Error al guardar historial: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearHistory() async {
    try {
      await localDataSource.clearHistory();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Error al limpiar historial: $e'));
    }
  }
}
